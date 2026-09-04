//
//  NSBundle+Posix.m
//  MulleObjCOSFoundation
//
//  Copyright (c) 2017 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
#define _GNU_SOURCE

#import "import-private.h"

// other libraries of MulleObjCPosixFoundation
#import <MulleObjCOSBaseFoundation/NSBundle-Private.h>

// std-c and dependencies
#include <dlfcn.h>
#include <errno.h>


// MEMO: statically linked classes can't figure out their bundle for resources.
//       Where do statically linked resources end up anyway ?
//
//       If foo.a is installed in /opt/whatever/lib/libfoo.a and the resources in
//       /opt/whatever/share/foo, there is no good ways to figure out that
//       /opt/whatever is the bundle root. Also there is no reference to
//       foo.
//       Conceivably we could place a bundle identifier into the class at
//       compile time ? And search some standard searchpath like /usr/ and
//       /usr/local for a matching bundle.
//
@implementation NSBundle( Posix)

// TODO: alias +load/+unload to loadBundle/unloadBundle for compatibility and
//       hide warning
//


+ (BOOL) isBundleFilesystemExtension:(NSString *) extension
{
   return( [extension isEqualToString:@"so"]);
}


- (NSString *) _posixResourcePath
{
   NSString   *s;
   NSString   *name;

   s    = [self executablePath];
   name = [[s lastPathComponent] stringByDeletingPathExtension];
   if( [name hasPrefix:@"lib"] && [[self class] isBundleFilesystemExtension:[s pathExtension]])
      name = [name substringFromIndex:3];

   s = [s stringByDeletingLastPathComponent]; // remove a.out
   s = [s stringByDeletingLastPathComponent]; // remove bin
   s = [s stringByAppendingPathComponent:@"share"]; // add share
   s = [s stringByAppendingPathComponent:name];  // add name of bundle

   return( s);
}


- (NSString *) _resourcePath
{
   return( [self _posixResourcePath]);
}


- (NSString *) builtInPlugInsPath
{
   return( [[self resourcePath] stringByAppendingPathComponent:@"plugin"]);
}


- (NSString *) _executablePath
{
   NSFileManager   *fileManager;
   NSString        *lastComponent;

   if( ! _path)
      return( _path);

   fileManager = [NSFileManager defaultManager];
   if( [fileManager isExecutableFileAtPath:_path])
      return( _path);
   // .so files on Linux are not executable, but dlopen only needs +r
   // Check pathExtension (libfoo.so) or if filename contains .so (libfoo.so.6)
   lastComponent = [_path lastPathComponent];
   if( [[self class] isBundleFilesystemExtension:[_path pathExtension]]
       || [lastComponent rangeOfString:@".so"].length)
   {
      if( [fileManager isReadableFileAtPath:_path])
         return( _path);
   }
   return( nil);
}


+ (NSBundle *) bundleForClass:(Class) aClass
{
   NSDictionary                     *bundleInfo;
   NSBundle                         *bundle;
   void                             *classAddress;
   struct _MulleObjCSharedLibrary   libInfo;
   NSString                         *path;
   NSString                         *bundlePath;
   NSString                         *exePath;
#ifndef __MULLE_COSMOPOLITAN__
   Dl_info                          info;
#endif

   if( ! aClass)
      return( nil);

   classAddress = MulleObjCClassGetLoadAddress( aClass);
   // if there is no load address, it was generated dynamically at runtime
   // e.g. NSZombie
   if( ! classAddress)
      return( [NSBundle mainBundle]);

#ifndef __MULLE_COSMOPOLITAN__
   if( dladdr( classAddress, &info))
   {
      path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:(char *) info.dli_fname
                                                                         length:strlen( info.dli_fname)];
      bundleInfo = [self mulleRegisteredBundleInfo];
      for( bundlePath in bundleInfo)
      {
         bundle  = [bundleInfo objectForKey:bundlePath];
         exePath = [bundle executablePath];
         if( [exePath isEqualToString:path])
         {
            return( bundle);
         }
      }
   }


   //
   // spec demands to create a bundle for the class now
   // Does it demand we register it ? If we don't the same
   // class will reside in different bundles over time
   // (Not caring right now)
   //
   libInfo.path   = nil;
   libInfo.start  = classAddress;
   libInfo.end    = classAddress;
   libInfo.handle = NULL;  // don't try to evict on unload

   path          = [NSString stringWithFormat:@"/pseudoproc/memory/%llx", classAddress];
   bundle        = [[[self alloc] _mulleInitWithPath:path
                                   sharedLibraryInfo:&libInfo] autorelease];
   return( bundle);
#else
   // not sure how to get here though
   MulleObjCThrowInvalidArgumentExceptionUTF8String( "Cosmopolitan can't do shared libraries");
#endif
   return( nil);
}


static char   *executablePathFileSytemRepresentation( NSBundle *self)
{
   NSString  *exePath;
   char      *c_path;

   exePath  = [self executablePath];
   c_path   = [exePath fileSystemRepresentation];
   if( ! c_path)
      errno = EINVAL;
   return( c_path);
}


- (BOOL) loadBundle
{
   char      *c_path;

   if( _handle)
      return( YES);

   c_path = executablePathFileSytemRepresentation( self);
   if( ! c_path)
   {
      dlerror(); // reset so next time it's NULL indicating errno to be used
      return( NO);
   }

   [self willLoad];

   // check to see if already loaded
   // RTLD_LAZY | RTLD_GLOBAL crashed for me
   _handle = dlopen( c_path, RTLD_LAZY);
   if( ! _handle)
      return( NO);

   [self didLoad];

   return( YES);
}


static char   *dlerror_or_errno( int errnocode)
{
   char  *s;

   s = dlerror();
   if( ! s && errnocode)
      s = strerror( errnocode);
   return( s ? s : "???");
}


- (BOOL) unloadBundle
{
   if( ! _handle)
      return( NO);

   if( dlclose( _handle))
      MulleObjCThrowInternalInconsistencyException( @"dlclose: %s", dlerror_or_errno( 0));
   _handle = NULL;
   return( YES);
}


- (NSString *) _loadFailureReason
{
   // BUG: Can the load failure be obscured by another thread using NSBundle ?
   return( [NSString stringWithCString:dlerror_or_errno( 0)]);
}

@end


@implementation NSBundle( MulleSymbolLookup)

- (void *) mulleLookupSymbolUTF8String:(char *) name
{
   if( ! name || ! _handle)
      return( NULL);
   return( dlsym( _handle, name));
}


- (void *) mulleLookupSymbol:(NSString *) name
{
   return( [self mulleLookupSymbolUTF8String:(char *) [name UTF8String]]);
}

@end

//
//  NSBundle+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#define _GNU_SOURCE

#import "import-private.h"

// other libraries of MulleObjCPosixFoundation
#import <MulleObjCOSBaseFoundation/private/NSBundle-Private.h>

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

   if( ! _path)
      return( _path);

   fileManager = [NSFileManager defaultManager];
   if( [fileManager isExecutableFileAtPath:_path])
      return( _path);
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
   Dl_info                          info;

   if( ! aClass)
      return( nil);

   classAddress = MulleObjCClassGetLoadAddress( aClass);
   // if there is no load address, it was generated dynamically at runtime
   // e.g. NSZombie
   if( ! classAddress)
      return( [NSBundle mainBundle]);

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
   char  *s;

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

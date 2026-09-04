//
//  NSPathUtilities+Linux.m
//  MulleObjCOSFoundation
//
//  Copyright (c) 2016 Nat! - Mulle kybernetiK.
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

// other files in this library

// other libraries of MulleObjCPosixFoundation
#import <MulleObjCOSBaseFoundation/NSPathUtilities+OSBase-Private.h>


// just like FreeBSD not much thought invested

static NSString   *LinuxHomeDirectory( void)
{
   char  *s;

   s = getenv( "HOME");
   if( s)
      return( [NSString stringWithCString:s]);
   return( @"");  // compatible with bash
}


static NSString   *LinuxRootDirectory( void)
{
   return( @"/");
}


static NSString   *LinuxTemporaryDirectory( void)
{
   char  *s;

   s = getenv( "TMPDIR");
   if( ! s)
      s = "/tmp";

   return( [NSString stringWithCString:s]);
}


static NSString   *LinuxUserName( void)
{
   char  *s;

   s = getenv( "USER");
   if( ! s)
      s = getenv( "LOGNAME");

   return( [NSString stringWithCString:s]);
}


static NSString  *pathForType( NSSearchPathDirectory type, NSSearchPathDomainMask domain)
{
   NSString  *path;

   path = nil;
   switch( type)
   {
   case NSApplicationDirectory          : path = (domain == NSLocalDomainMask) ? nil : @"bin"; break;
   case NSDeveloperApplicationDirectory : path = (domain == NSLocalDomainMask) ? nil : @"Developer/Applications"; break;
   case NSDeveloperDirectory            : path = (domain == NSLocalDomainMask) ? nil : @"Developer"; break;
   case NSAdminApplicationDirectory     : path = (domain == NSLocalDomainMask) ? nil : @"sbin"; break;
   case NSLibraryDirectory              : path = (domain == NSLocalDomainMask) ? @"" : @"lib"; break;
   case NSApplicationSupportDirectory   : path = (domain == NSLocalDomainMask) ? nil : @"libexec"; break;
   case NSUserDirectory                 : path = (domain == NSUserDomainMask) ? @"" : nil; break;
   case NSMusicDirectory                : path = (domain == NSUserDomainMask) ? @"Music" : nil; break;
   case NSMoviesDirectory               : path = (domain == NSUserDomainMask) ? @"Movies" : nil; break;
   case NSPicturesDirectory             : path = (domain == NSUserDomainMask) ? @"Pictures" : nil; break;
   case NSCachesDirectory               : path = @"caches"; break;
   case NSDocumentationDirectory        : path = @"man"; break;
   case NSDocumentDirectory             : path = (domain == NSUserDomainMask) ? @"Documents" : nil; break;
   case NSDesktopDirectory              : path = (domain == NSUserDomainMask) ? @"Desktop" : nil; break;
   }
   return( path);
}


static void  addPrefixedPathForType( NSMutableArray *array, NSString *prefix, NSSearchPathDirectory type, NSSearchPathDomainMask domain)
{
   NSString  *path;

   path = pathForType( type, domain);
   if( path)
   {
      path = [prefix stringByAppendingPathComponent:path];
      [array addObject:path];
   }
}



static NSArray   *LinuxSearchPathForDirectoriesInDomains( NSSearchPathDirectory type,
                                                          NSSearchPathDomainMask domains)
{
   NSMutableArray           *array;
   NSSearchPathDomainMask   currentDomain;
   NSSearchPathDomainMask   leftoverDomains;
   NSString                 *systemRoot;
   NSString                 *prefix;

   systemRoot      = NSOpenStepRootDirectory();
   array           = [NSMutableArray array];
   leftoverDomains = domains & (NSUserDomainMask|NSLocalDomainMask|NSNetworkDomainMask|NSSystemDomainMask);

   NSCParameterAssert( [systemRoot length]);

   while( leftoverDomains)
   {
      if( leftoverDomains & NSUserDomainMask)
      {
         currentDomain = NSUserDomainMask;
         prefix        = @"~";
      }
      else
         if( leftoverDomains & NSLocalDomainMask)
         {
            currentDomain = NSLocalDomainMask;
            prefix        = @"/usr/lib";
         }
         else
            if( leftoverDomains & NSNetworkDomainMask)
            {
               currentDomain = NSNetworkDomainMask;
               prefix        = @"/var/net";   // no idea
            }
            else
            {
               currentDomain = NSSystemDomainMask;
               prefix        = systemRoot;
            }

      leftoverDomains &= ~currentDomain;

      switch( type)
      {
      case NSAllApplicationsDirectory : // fake but better than nothing
         addPrefixedPathForType( array, prefix, NSApplicationDirectory, currentDomain);
         addPrefixedPathForType( array, prefix, NSAdminApplicationDirectory, currentDomain);
         addPrefixedPathForType( array, prefix, NSDeveloperApplicationDirectory, currentDomain);
         break;

      case NSAllLibrariesDirectory  :
         addPrefixedPathForType( array, prefix, NSLibraryDirectory, currentDomain);
         addPrefixedPathForType( array, prefix, NSDeveloperDirectory, currentDomain);  // curious but compatible
         break;

      default :
         addPrefixedPathForType( array, prefix, type, currentDomain);
         break;
      }
   }
   // TODO: code needed!!
   return( array);
}


static _NSPathUtilityVectorTable   _LinuxTable =
{
   LinuxUserName,
   LinuxHomeDirectory,
   NULL,
   LinuxSearchPathForDirectoriesInDomains,
   LinuxRootDirectory,
   LinuxTemporaryDirectory,
   LinuxUserName
};


@implementation _NSPathUtilityVectorTable_Loader( Linux)

@dependency _NSPathUtilityVectorTable_Loader;


+ (void) load
{
   _NSPathUtilityVectors = &_LinuxTable;
}

@end


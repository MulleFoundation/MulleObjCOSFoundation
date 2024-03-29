/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSPathUtilities+Darwin.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, __MyCompanyName__
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#define _DARWIN_C_SOURCE

#import "import-private.h"

// other files in this library
#import <MulleObjCOSBaseFoundation/NSPathUtilities+OSBase-Private.h>

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies

//
// use DSCL to figure it out, and it's best to run a shell command on it
// because then we don't need to link to anything
//

static NSString  *_NSUserRegistryValueForKey( NSString *user, NSString *key)
{
   NSString       *result;
   NSString       *path;
   NSRange        range;
   char           *dscl;
   NSArray        *arguments;
   NSDictionary   *dict;

   // is this a security hole ?
   dscl = getenv( "DSCL_UTILITY_PATH");
   if( ! dscl)
      dscl = "/usr/bin/dscl";

   //    sysdscl -raw . -read /Users/nat RealName

//   s      = [NSString stringWithFormat:@"%s -raw . -read /Users/%@ %@", dscl, user, key];
   path      = [@"/Users/" stringByAppendingString:user];
   arguments = [NSArray arrayWithObjects:[NSString stringWithUTF8String:dscl], @"-raw", @".", @"-read", path, key, nil];
   dict      = [NSTask mulleStringSystemCallWithArguments:arguments
                                      standardInputString:nil];
   result    = [dict objectForKey:NSTaskStandardOutputStringKey];
   if( ! result)
      return( nil);

   range = [result rangeOfString:@": "];
   if( ! range.length)
      return( nil);

   return( [result substringFromIndex:range.location + range.length]);
}



static NSString   *DarwinFullUserName( void)
{
   return( _NSUserRegistryValueForKey( NSUserName(), @"RealName"));
}


static NSString   *DarwinHomeDirectoryForUser( NSString *user)
{
   // TODO: reenable, when we got charset support
   // NSCParameterAssert( [user rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0);

   return( _NSUserRegistryValueForKey( user, @"NFSHomeDirectory"));
}


static NSString   *DarwinHomeDirectory( void)
{
   char  *s;

   s = getenv( "HOME");
   if( s)
      return( [NSString stringWithCString:s]);

   return( DarwinHomeDirectoryForUser( NSUserName()));
}


static NSString   *DarwinOpenStepRootDirectory( void)
{
   return( @"/");
}


static NSString   *DarwinTemporaryDirectory( void)
{
   char  *s;

   s = getenv( "TMPDIR");
   if( ! s)
      s = "/tmp";

   return( [NSString stringWithCString:s]);
}


static NSString   *DarwinUserName( void)
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
   case NSApplicationDirectory          : path = (domain == NSLocalDomainMask) ? nil : @"Applications"; break;
   case NSDeveloperApplicationDirectory : path = (domain == NSLocalDomainMask) ? nil : @"Developer/Applications"; break;
   case NSDeveloperDirectory            : path = (domain == NSLocalDomainMask) ? nil : @"Developer"; break;
   case NSAdminApplicationDirectory     : path = (domain == NSLocalDomainMask) ? nil : @"Applications/Utiltities"; break;
   case NSLibraryDirectory              : path = (domain == NSLocalDomainMask) ? @"" : @"Library"; break;
   case NSApplicationSupportDirectory   : path = (domain == NSLocalDomainMask) ? nil : @"Library/Application Support"; break;
   case NSUserDirectory                 : path = (domain == NSUserDomainMask) ? @"" : nil; break;
   case NSMusicDirectory                : path = (domain == NSUserDomainMask) ? @"Music" : nil; break;
   case NSMoviesDirectory               : path = (domain == NSUserDomainMask) ? @"Movies" : nil; break;
   case NSPicturesDirectory             : path = (domain == NSUserDomainMask) ? @"Pictures" : nil; break;
   case NSCachesDirectory               : path = @"Library/Caches"; break;
   case NSDocumentationDirectory        : path = @"Library/Documentation"; break;
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

static NSArray   *DarwinSearchPathForDirectoriesInDomains( NSSearchPathDirectory type,
                                                         NSSearchPathDomainMask domains)
{
   NSMutableArray          *array;
   NSSearchPathDomainMask  currentDomain;
   NSSearchPathDomainMask  leftoverDomains;
   NSString                *prefix;
   NSString                *systemRoot;

   systemRoot      = [NSOpenStepRootDirectory() stringByAppendingPathComponent:@"System"];
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
            prefix        = @"/Library";
         }
         else
            if( leftoverDomains & NSNetworkDomainMask)
            {
               currentDomain = NSNetworkDomainMask;
               prefix        = @"/Network";
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

      default                              :
         addPrefixedPathForType( array, prefix, type, currentDomain);
         break;
      }
   }
   return( array);
}


static _NSPathUtilityVectorTable   _DarwinTable =
{
   DarwinFullUserName,
   DarwinHomeDirectory,
   DarwinHomeDirectoryForUser,
   DarwinSearchPathForDirectoriesInDomains,
   DarwinOpenStepRootDirectory,
   DarwinTemporaryDirectory,
   DarwinUserName
};


@implementation _NSPathUtilityVectorTable_Loader( Darwin)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCBSDFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}


+ (void) load
{
   _NSPathUtilityVectors = &_DarwinTable;
}

@end



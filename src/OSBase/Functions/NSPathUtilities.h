/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSPathUtilities.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "import.h"


enum
{
   NSUserDomainMask    = 1,
   NSLocalDomainMask   = 2,
   NSNetworkDomainMask = 4,
   NSSystemDomainMask  = 8,
   NSAllDomainsMask    = ~0
};

typedef NSUInteger   NSSearchPathDomainMask;


enum {
   NSApplicationDirectory = 1,
   NSAdminApplicationDirectory,
   NSApplicationSupportDirectory,
   NSCachesDirectory,
   NSDesktopDirectory,
   NSDeveloperApplicationDirectory,
   NSDeveloperDirectory,
   NSDocumentationDirectory,
   NSDocumentDirectory,
   NSLibraryDirectory,
   NSMoviesDirectory,
   NSMusicDirectory,
   NSPicturesDirectory,
   NSSharedPublicDirectory,
   NSTrashDirectory,
   NSUserDirectory,
   NSAllApplicationsDirectory,
   NSAllLibrariesDirectory,
};
typedef NSUInteger NSSearchPathDirectory;


@class NSString;
@class NSArray;



MULLE_OBJC_OSBASE_FOUNDATION_EXTERN_GLOBAL
NSString  *NSFullUserName( void);

MULLE_OBJC_OSBASE_FOUNDATION_EXTERN_GLOBAL
NSString  *NSHomeDirectory( void);

MULLE_OBJC_OSBASE_FOUNDATION_EXTERN_GLOBAL
NSString  *NSHomeDirectoryForUser( NSString *userName);

MULLE_OBJC_OSBASE_FOUNDATION_EXTERN_GLOBAL
NSString  *NSOpenStepRootDirectory( void);

MULLE_OBJC_OSBASE_FOUNDATION_EXTERN_GLOBAL
NSArray   *NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory directory,
                                                NSSearchPathDomainMask domainMask,
                                                BOOL expandTilde);
MULLE_OBJC_OSBASE_FOUNDATION_EXTERN_GLOBAL
NSString  *NSTemporaryDirectory( void);

MULLE_OBJC_OSBASE_FOUNDATION_EXTERN_GLOBAL
NSString  *NSUserName( void);


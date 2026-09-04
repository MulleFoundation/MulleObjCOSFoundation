//
//  NSPathUtilities.h
//  MulleObjCOSFoundation
//
//  Copyright (c) 2020 Nat! - Mulle kybernetiK.
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



MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL
NSString  *NSFullUserName( void);

MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL
NSString  *NSHomeDirectory( void);

MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL
NSString  *NSHomeDirectoryForUser( NSString *userName);

MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL
NSString  *NSOpenStepRootDirectory( void);

MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL
NSArray   *NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory directory,
                                                NSSearchPathDomainMask domainMask,
                                                BOOL expandTilde);
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL
NSString  *NSTemporaryDirectory( void);

MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL
NSString  *NSUserName( void);


/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSProcessInfo.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import <MulleObjCFoundation/MulleObjCFoundation.h>


enum 
{
   NSWindowsNTOperatingSystem = 1,
   NSWindows95OperatingSystem,
   NSSolarisOperatingSystem,
   NSHPUXOperatingSystem,
   NSDarwinOperatingSystem,
   NSSunOSOperatingSystem,
   NSOSF1OperatingSystem,
   NSLinuxOperatingSystem,
   NSBSDOperatingSystem
};


@interface NSProcessInfo : NSObject
{
   NSArray       *_arguments;
   NSDictionary  *_environment;
}

+ (NSProcessInfo *) processInfo;

- (NSString *) globallyUniqueString;
- (NSString *) hostName;
- (NSUInteger) operatingSystem;
- (NSString *) operatingSystemName;
- (NSString *) operatingSystemVersionString;
- (int) processIdentifier;
- (NSString *) processName;
- (void) setProcessName:(NSString *) name;

@end


@interface NSProcessInfo ( OSSpecific)

- (NSArray *) arguments;
- (NSDictionary *) environment;

@end

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
#import "import.h"


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


//
// MEMO: this is supposed to be threadsafe, gotta take care of this though
//
@interface NSProcessInfo : NSObject < MulleObjCSingleton, MulleObjCThreadSafe>
{
   NSArray       *_arguments;
   NSDictionary  *_environment;
   NSString      *_executablePath;
}


+ (NSProcessInfo *) processInfo;

@end


@interface NSProcessInfo ( Future)

- (NSString *) hostName;

- (NSUInteger) operatingSystem;
- (NSString *) operatingSystemName;
- (NSString *) operatingSystemVersionString;

- (NSArray *) arguments;
- (NSDictionary *) environment;
- (NSString *) _executablePath;

- (NSString *) processName;
- (void) setProcessName:(NSString *) name;

- (NSString *) globallyUniqueString;  // needs NSHost should be moved
- (int) processIdentifier;

// calls setenv (and modifies _environment)
- (void) mulleSetEnvironmentValue:(NSString *) value 
                           forKey:(NSString *) key;
@end

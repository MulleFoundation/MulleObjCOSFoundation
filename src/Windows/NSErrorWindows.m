//
//  NSError+Windows.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 23.01.26
//  Copyright © 2026 Mulle kybernetiK. All rights reserved.
//
#import "import-private.h"


MULLE_OBJC_WINDOWS_FOUNDATION_GLOBAL_VAR
NSString   *NSWindowsErrorDomain = @"NSWindowsError";


void   MulleObjCSetWindowsErrorDomain( void)
{
   [NSError mulleSetErrorDomain:NSWindowsErrorDomain];
}

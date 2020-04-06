//
//  NSError+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 05.04.20
//  Copyright © 2020 Mulle kybernetiK. All rights reserved.
//
#import "import-private.h"


NSString   *NSPOSIXErrorDomain = @"NSPOSIXError";


void   MulleObjCSetPosixErrorDomain( void)
{
   [NSError mulleSetErrorDomain:NSPOSIXErrorDomain];
}

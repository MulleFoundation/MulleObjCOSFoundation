//
//  NSProcessInfo+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#define _XOPEN_SOURCE 700

#import "import-private.h"

// other files in this library
#import "NSError+Posix.h"


// std-c and dependencies
#include <unistd.h>


@implementation NSProcessInfo (Posix)

- (int) processIdentifier
{
   MulleObjCSetPosixErrorDomain();

   return( getpid());
}

@end

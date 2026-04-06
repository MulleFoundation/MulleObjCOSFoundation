//
//  NSTask+Linux.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 29.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#define _GNU_SOURCE

#import "import-private.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation



@implementation NSTask( Linux)

@dependency NSTask( Posix);


+ (char **) _environment
{
   extern char  **environ;

   return( environ);
}

@end

//
//  NSPipe+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "import-private.h"

// other files in this library
#import "NSError+Posix.h"

// std-c and dependencies
#include <unistd.h>


@implementation NSPipe (Posix)

static id    NSInitPipe( NSPipe *self)
{
   int   fds[ 2];

   MulleObjCSetPosixErrorDomain();

   if( pipe( fds))
      return( nil);

   self->_read  = [[NSFileHandle alloc] initWithFileDescriptor:fds[ 0]
                                                closeOnDealloc:YES];
   self->_write = [[NSFileHandle alloc] initWithFileDescriptor:fds[ 1]
                                                closeOnDealloc:YES];

   return( self);
}


- (instancetype) init
{
   return( NSInitPipe( self));
}

@end

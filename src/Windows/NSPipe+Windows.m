//
//  NSPipe+Windows.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 24.01.26
//  Copyright © 2026 Mulle kybernetiK. All rights reserved.
//
#import "import-private.h"

// other files in this library
#import "NSErrorWindows.h"

// std-c and dependencies
#include <windows.h>


@implementation NSPipe( Windows)

static id NSInitPipe( NSPipe *self)
{
   HANDLE            hRead, hWrite;
   SECURITY_ATTRIBUTES sa;
   
   MulleObjCSetWindowsErrorDomain();
   
   // Setup security attributes for inheritable handles
   sa.nLength              = sizeof( SECURITY_ATTRIBUTES);
   sa.bInheritHandle       = TRUE;
   sa.lpSecurityDescriptor = NULL;
   
   // Create anonymous pipe - both ends inheritable initially
   if( ! CreatePipe( &hRead, &hWrite, &sa, 0))
      return( nil);
   
   // Create file handles from Windows HANDLEs
   self->_read  = [[NSFileHandle alloc] initWithFileDescriptor:(int) (intptr_t) hRead
                                                closeOnDealloc:YES];
   self->_write = [[NSFileHandle alloc] initWithFileDescriptor:(int) (intptr_t) hWrite
                                                closeOnDealloc:YES];
   
   return( self);
}


- (instancetype) init
{
   return( NSInitPipe( self));
}

@end

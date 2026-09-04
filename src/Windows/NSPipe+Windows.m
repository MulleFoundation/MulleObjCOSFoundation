//
//  NSPipe+Windows.m
//  MulleObjCOSFoundation
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
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

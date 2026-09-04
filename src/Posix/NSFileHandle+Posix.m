//
//  NSFileHandle+Posix.m
//  MulleObjCOSFoundation
//
//  Copyright (c) 2017 Nat! - Mulle kybernetiK.
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
#define _XOPEN_SOURCE 700

#import "import-private.h"

#import "NSError+Posix.h"

// std-c and dependencies
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>


@implementation NSFileHandle (Posix)

#pragma mark - open

+ (instancetype) _fileHandleWithPath:(NSString *) path
                                mode:(enum _MulleObjCOpenMode) mode
{
   char   *s;
   int    fd;
   int    posixMode;

   MulleObjCSetPosixErrorDomain();

   // compiler should eliminate this
   switch( mode)
   {
   case _MulleObjCOpenReadOnly:    posixMode = O_RDONLY; break;
   case _MulleObjCOpenWriteOnly :  posixMode = O_WRONLY; break;
   case _MulleObjCOpenReadWrite :  posixMode = O_RDWR; break;
   }

   s  = [path fileSystemRepresentation];
   fd = open( s, posixMode);
   if( fd == -1)
      return( nil);
   return( [[[self alloc] initWithFileDescriptor:fd
                                  closeOnDealloc:YES] autorelease]);
}


static int   close_void_ptr( void *p)
{
   return( close( (int)(intptr_t) p));
}


static int   no_close_void_ptr( void *p)
{
   return( 0);
}



static id  NSInitFileHandleNoClose( NSFileHandle *self, int fd)
{
   self->_fd     = (void *) (intptr_t) fd;
   self->_closer = no_close_void_ptr;
   return( self);
}


static id  NSInitFileHandleAndClose( NSFileHandle *self, int fd)
{
   self->_fd     = (void *) (intptr_t) fd;
   self->_closer = close_void_ptr;
   return( self);
}


- (instancetype) initWithFileDescriptor:(int) fd
                         closeOnDealloc:(BOOL) flag
{
   if( flag)
      return( NSInitFileHandleAndClose( self, fd));
   return( NSInitFileHandleNoClose( self, fd));
}


+ (instancetype) fileHandleWithStandardInput
{
   return( NSAutoreleaseObject( NSInitFileHandleNoClose( NSAllocateObject( self, 0, NULL), 0)));
}


+ (instancetype) fileHandleWithStandardOutput
{
   return( NSAutoreleaseObject( NSInitFileHandleNoClose( NSAllocateObject( self, 0, NULL), 1)));
}


+ (instancetype) fileHandleWithStandardError
{
   return( NSAutoreleaseObject( NSInitFileHandleNoClose( NSAllocateObject( self, 0, NULL), 2)));
}


#pragma mark - read

- (ssize_t) _readBytes:(void *) buf
                length:(size_t) len
{
   ssize_t  result;

   MulleObjCSetPosixErrorDomain();

retry:
   result = read( (int) (intptr_t) _fd, buf, len);
   if( result == -1)
   {
      // can't switch this because of cosmopolitan
      if( errno == EINTR)
         goto retry;

      if( errno == EPIPE)
      {
         NSUIntegerAtomicOr( &self->_state, NSFileHandleStateEOF|NSFileHandleStatePipe);
         return( 0);
      }

      if( errno == EAGAIN)
      {
         NSUIntegerAtomicOr( &self->_state, NSFileHandleStateAgain);
         return( 0);
      }

      MulleObjCThrowErrnoException( @"read");
   }

   // _state.eof  = len && ! result;
   NSUIntegerAtomicMaskedOr( &self->_state,
                             ~NSFileHandleStateEOF,
                             (len && ! result) ? NSFileHandleStateEOF : 0);

   return( result);
}


#pragma mark - write

- (size_t) _writeBytes:(void *) buf
                length:(size_t) len
{
   ssize_t   result;

   NSParameterAssert( buf || ! len);
   NSParameterAssert( len != (size_t) -1);

   MulleObjCSetPosixErrorDomain();

retry:
   result = write( (int)(intptr_t) _fd, buf, len);
   if( result == -1)
   {
      // can't switch this because of cosmopolitan
      if( errno == EINTR)
         goto retry;

      if( errno == EPIPE)
      {
         NSUIntegerAtomicOr( &self->_state, NSFileHandleStateEOF|NSFileHandleStatePipe);
         return( 0);
      }

      if( errno == EAGAIN)
      {
         NSUIntegerAtomicOr( &self->_state, NSFileHandleStateAgain);
         return( 0);
      }

      MulleObjCThrowErrnoException( @"write");
   }

   NSUIntegerAtomicMaskedOr( &self->_state,
                             ~NSFileHandleStateEOF,
                             (len && ! result) ? NSFileHandleStateEOF : 0);
   return( (size_t) result);
}


#pragma mark - write
#pragma mark - seek

- (unsigned long long) _seek:(unsigned long long) offset
                        mode:(enum _MulleObjCSeekMode) mode
{
   off_t   result;
   int     posixMode;

   MulleObjCSetPosixErrorDomain();

   // compiler should eliminate this
   switch( mode)
   {
   case _MulleObjCSeekCur:  posixMode = SEEK_CUR; break;
   case _MulleObjCSeekSet:  posixMode = SEEK_SET; break;
   case _MulleObjCSeekEnd:  posixMode = SEEK_END; break;
   }

   result = lseek( (int)(intptr_t) _fd, offset, posixMode);
   if( result == -1)
   {
      // can't switch this because of cosmopolitan
      if( errno != ENXIO)
      {
         if( errno == EPIPE)
         {
            NSUIntegerAtomicOr( &self->_state, NSFileHandleStateEOF|NSFileHandleStatePipe);
            return( 0);
         }

         MulleObjCThrowErrnoException( @"lseek");
      }
   }
   return( (unsigned long long) result);
}


#pragma mark - sync

- (void) synchronizeFile
{
   sync();
}

@end

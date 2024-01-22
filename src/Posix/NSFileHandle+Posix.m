//
//  NSFileHandle+Posix_m.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
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
         _state.eof  = 1;
         _state.pipe = 1;
         return( 0);
      }

      if( errno == EAGAIN)
      {
         _state.again = 1;
         return( 0);
      }

      MulleObjCThrowErrnoException( @"read");
   }
   _state.eof  = len && ! result;
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
         _state.eof  = 1;
         _state.pipe = 1;
         return( 0);
      }

      if( errno == EAGAIN)
      {
         _state.again = 1;
         return( 0);
      }

      MulleObjCThrowErrnoException( @"write");
   }

   _state.eof = len && ! result;
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
            _state.eof  = 1;
            _state.pipe = 1;
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

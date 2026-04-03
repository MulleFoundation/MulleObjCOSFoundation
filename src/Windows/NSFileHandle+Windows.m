//
//  NSFileHandle+Windows.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 24.01.26
//  Copyright © 2026 Mulle kybernetiK. All rights reserved.
//
#import "import-private.h"

#import "NSErrorWindows.h"

// std-c and dependencies
#include <windows.h>


@implementation NSFileHandle( Windows)

#pragma mark - open

+ (instancetype) _fileHandleWithPath:(NSString *) path
                                mode:(enum _MulleObjCOpenMode) mode
{
   NSUInteger len;
   HANDLE    hFile;
   DWORD     accessMode;
   DWORD     shareMode;
   DWORD     creationDisposition;

   MulleObjCSetWindowsErrorDomain();

   // Map mode to Windows access flags
   switch( mode)
   {
   case _MulleObjCOpenReadOnly:
      accessMode           = GENERIC_READ;
      shareMode            = FILE_SHARE_READ;
      creationDisposition  = OPEN_EXISTING;
      break;

   case _MulleObjCOpenWriteOnly:
      accessMode           = GENERIC_WRITE;
      shareMode            = 0;
      creationDisposition  = OPEN_ALWAYS;
      break;

   case _MulleObjCOpenReadWrite:
      accessMode           = GENERIC_READ | GENERIC_WRITE;
      shareMode            = 0;
      creationDisposition  = OPEN_ALWAYS;
      break;
   }

   len = [path length];

   mulle_alloca_do( utf32, unichar, len)
   {
      mulle_alloca_do( widePath, wchar_t, len + 1)
      {
         [path getCharacters:utf32 range:NSMakeRange( 0, len)];
         _mulle_utf32_convert_to_utf16( (mulle_utf32_t *) utf32, len, (mulle_utf16_t *) widePath);
         widePath[ len] = 0;

         hFile = CreateFileW( widePath,
                              accessMode,
                              shareMode,
                              NULL,
                              creationDisposition,
                              FILE_ATTRIBUTE_NORMAL,
                              NULL);
      }
   }

   if( hFile == INVALID_HANDLE_VALUE)
      return( nil);

   return( [[[self alloc] initWithFileDescriptor:(int) (intptr_t) hFile
                                  closeOnDealloc:YES] autorelease]);
}


static int close_handle( void *p)
{
   return( CloseHandle( (HANDLE) p) ? 0 : -1);
}


static int no_close_handle( void *p)
{
   return( 0);
}


static id NSInitFileHandleNoClose( NSFileHandle *self, HANDLE handle)
{
   self->_fd     = handle;
   self->_closer = no_close_handle;
   return( self);
}


static id NSInitFileHandleAndClose( NSFileHandle *self, HANDLE handle)
{
   self->_fd     = handle;
   self->_closer = close_handle;
   return( self);
}


- (instancetype) initWithFileDescriptor:(int) fd
                         closeOnDealloc:(BOOL) flag
{
   HANDLE   handle = (HANDLE) (intptr_t) fd;

   if( flag)
      return( NSInitFileHandleAndClose( self, handle));
   return( NSInitFileHandleNoClose( self, handle));
}


+ (instancetype) fileHandleWithStandardInput
{
   HANDLE   hStdin = GetStdHandle( STD_INPUT_HANDLE);
   return( NSAutoreleaseObject( NSInitFileHandleNoClose( NSAllocateObject( self, 0, NULL), hStdin)));
}


+ (instancetype) fileHandleWithStandardOutput
{
   HANDLE   hStdout = GetStdHandle( STD_OUTPUT_HANDLE);
   return( NSAutoreleaseObject( NSInitFileHandleNoClose( NSAllocateObject( self, 0, NULL), hStdout)));
}


+ (instancetype) fileHandleWithStandardError
{
   HANDLE   hStderr = GetStdHandle( STD_ERROR_HANDLE);
   return( NSAutoreleaseObject( NSInitFileHandleNoClose( NSAllocateObject( self, 0, NULL), hStderr)));
}


#pragma mark - read

- (ssize_t) _readBytes:(void *) buf
                length:(size_t) len
{
   DWORD     bytesRead;
   HANDLE    hFile;

   MulleObjCSetWindowsErrorDomain();

   hFile = (HANDLE) _fd;

   if( ! ReadFile( hFile, buf, (DWORD) len, &bytesRead, NULL))
   {
      DWORD   error = GetLastError();

      if( error == ERROR_BROKEN_PIPE || error == ERROR_HANDLE_EOF)
      {
         NSUIntegerAtomicOr( &self->_state, NSFileHandleStateEOF | NSFileHandleStatePipe);
         return( 0);
      }

      MulleObjCThrowInternalInconsistencyException( @"ReadFile failed: %lu", error);
   }

   NSUIntegerAtomicMaskedOr( &self->_state,
                             ~NSFileHandleStateEOF,
                             (len && ! bytesRead) ? NSFileHandleStateEOF : 0);

   return( (ssize_t) bytesRead);
}


#pragma mark - write

- (size_t) _writeBytes:(void *) buf
                length:(size_t) len
{
   DWORD     bytesWritten;
   HANDLE    hFile;

   NSParameterAssert( buf || ! len);
   NSParameterAssert( len != (size_t) -1);

   MulleObjCSetWindowsErrorDomain();

   hFile = (HANDLE) _fd;

   if( ! WriteFile( hFile, buf, (DWORD) len, &bytesWritten, NULL))
   {
      DWORD   error = GetLastError();

      if( error == ERROR_BROKEN_PIPE)
      {
         NSUIntegerAtomicOr( &self->_state, NSFileHandleStateEOF | NSFileHandleStatePipe);
         return( 0);
      }

      MulleObjCThrowInternalInconsistencyException( @"WriteFile failed: %lu", error);
   }

   NSUIntegerAtomicMaskedOr( &self->_state,
                             ~NSFileHandleStateEOF,
                             (len && ! bytesWritten) ? NSFileHandleStateEOF : 0);

   return( (size_t) bytesWritten);
}


#pragma mark - seek

- (unsigned long long) _seek:(unsigned long long) offset
                        mode:(enum _MulleObjCSeekMode) mode
{
   LARGE_INTEGER   liOffset;
   LARGE_INTEGER   liNewPos;
   DWORD           moveMethod;
   HANDLE          hFile;

   MulleObjCSetWindowsErrorDomain();

   // Map seek mode
   switch( mode)
   {
   case _MulleObjCSeekCur:  moveMethod = FILE_CURRENT; break;
   case _MulleObjCSeekSet:  moveMethod = FILE_BEGIN; break;
   case _MulleObjCSeekEnd:  moveMethod = FILE_END; break;
   }

   hFile           = (HANDLE) _fd;
   liOffset.QuadPart = offset;

   if( ! SetFilePointerEx( hFile, liOffset, &liNewPos, moveMethod))
   {
      DWORD   error = GetLastError();

      if( error == ERROR_BROKEN_PIPE)
      {
         NSUIntegerAtomicOr( &self->_state, NSFileHandleStateEOF | NSFileHandleStatePipe);
         return( 0);
      }

      MulleObjCThrowInternalInconsistencyException( @"SetFilePointerEx failed: %lu", error);
   }

   return( (unsigned long long) liNewPos.QuadPart);
}


#pragma mark - sync

- (void) synchronizeFile
{
   FlushFileBuffers( (HANDLE) _fd);
}

@end

/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSData+Windows.m is a part of MulleObjCOSFoundation
 *
 *  Copyright (C) 2024 Mulle kybernetiK.
 *  All rights reserved.
 *
 */

#import "import-private.h"

// other files in this library
#import "NSErrorWindows.h"
#import "NSFileManager+Windows.h"
#import <MulleObjCOSBaseFoundation/NSPageAllocation-Private.h>

// Windows headers
#include <windows.h>


@implementation NSData( Windows)

+ (void) load
{
   _MulleObjCSetPageSize( mulle_mmap_get_system_pagesize());
}


- (instancetype) initWithContentsOfFile:(NSString *) path
{
   struct mulle_allocator   *allocator;
   HANDLE                   hFile;
   DWORD                    fileSize, bytesRead;
   char                     *buf;
   mulle_utf16_t            *widePath;

   MulleObjCSetWindowsErrorDomain();

   allocator = MulleObjCInstanceGetAllocator( self);
   widePath  = [[NSFileManager defaultManager] fileSystemRepresentationUTF16WithPath:path];

   hFile = CreateFileW( (WCHAR *) widePath,
                        GENERIC_READ,
                        FILE_SHARE_READ,
                        NULL,
                        OPEN_EXISTING,
                        FILE_ATTRIBUTE_NORMAL,
                        NULL);

   if( hFile == INVALID_HANDLE_VALUE)
   {
      [self release];
      return( nil);
   }

   fileSize = GetFileSize( hFile, NULL);
   if( fileSize == INVALID_FILE_SIZE)
   {
      CloseHandle( hFile);
      [self release];
      return( nil);
   }

   if( fileSize == 0)
   {
      CloseHandle( hFile);
      return( [self mulleInitWithBytesNoCopy:NULL length:0 allocator:NULL]);
   }

   buf = mulle_allocator_malloc( allocator, fileSize);
   if( ! buf)
   {
      CloseHandle( hFile);
      [self release];
      return( nil);
   }

   if( ! ReadFile( hFile, buf, fileSize, &bytesRead, NULL) || bytesRead != fileSize)
   {
      mulle_allocator_free( allocator, buf);
      CloseHandle( hFile);
      [self release];
      return( nil);
   }

   CloseHandle( hFile);

   return( [self mulleInitWithBytesNoCopy:buf
                                   length:fileSize
                                allocator:allocator]);
}


- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag
{
   NSFileManager       *manager;
   NSString            *new_path;
   HANDLE              hFile;
   DWORD               bytesWritten;
   struct mulle_data   data;
   BOOL                success;
   mulle_utf16_t       *widePath;

   MulleObjCSetWindowsErrorDomain();

   manager  = [NSFileManager defaultManager];
   new_path = flag ? [path stringByAppendingString:@"~"] : path;
   widePath = [manager fileSystemRepresentationUTF16WithPath:new_path];

   hFile = CreateFileW( (WCHAR *) widePath,
                        GENERIC_WRITE,
                        0,
                        NULL,
                        CREATE_ALWAYS,
                        FILE_ATTRIBUTE_NORMAL,
                        NULL);

   if( hFile == INVALID_HANDLE_VALUE)
      return( NO);

   data    = [self mulleCData];
   success = WriteFile( hFile, data.bytes, data.length, &bytesWritten, NULL);
   CloseHandle( hFile);

   if( ! success || bytesWritten != data.length)
      return( NO);

   if( ! flag)
      return( YES);

   // Atomic write: rename temp file to final name
   {
      mulle_utf16_t   *wideFinal;

      wideFinal = [manager fileSystemRepresentationUTF16WithPath:path];
      DeleteFileW( (WCHAR *) wideFinal);
      success = MoveFileW( (WCHAR *) widePath, (WCHAR *) wideFinal);
   }

   return( success ? YES : NO);
}


- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag
               error:(NSError **) p_error
{
   if( [self writeToFile:path
              atomically:flag])
      return( YES);

   if( p_error)
      *p_error = MulleObjCExtractError();
   return( NO);
}

@end

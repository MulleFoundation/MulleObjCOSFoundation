/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSFileManager+Windows.m is a part of MulleObjCOSFoundation
 *
 *  Copyright (C) 2024 Mulle kybernetiK.
 *  All rights reserved.
 *
 */

#import "import-private.h"
#import "NSFileManager+Windows.h"
#import "NSString+Windows.h"

// other files in this library
#import "NSErrorWindows.h"
#import <MulleObjCOSBaseFoundation/NSFileManager-Private.h>

// Windows headers
#include <windows.h>
// windows.h temporarily defines 'interface' as 'struct' for COM headers, but
// restores it via push/pop_macro on exit, leaving 'interface' undefined.
// shlwapi.h uses 'interface' via DECLARE_INTERFACE (combaseapi.h), so we must
// redefine it as 'struct' for the duration of this include.
#pragma push_macro("interface")
#define interface struct
#include <shlwapi.h>
#pragma pop_macro("interface")


@implementation NSFileManager( Windows)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCDeps), @selector( MulleObjCOSWindowsFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}




- (char *) fileSystemRepresentationWithPath:(NSString *) path
{
   NSString   *converted;

   converted = [path mulleWindowsFileSystemString];
   return( [converted UTF8String]);
}


- (mulle_utf16_t *) fileSystemRepresentationUTF16WithPath:(NSString *) path
{
   NSString   *converted;

   converted = [path mulleWindowsFileSystemString];
   return( [converted mulleUTF16String]);
}


- (NSString *) stringWithFileSystemRepresentation:(char *) s
                                           length:(NSUInteger) len
{
   NSString   *path;
   NSString   *converted;
   
   if( ! s)
      return( nil);
   
   path      = [NSString stringWithUTF8String:s];
   converted = [path mulleUnixFileSystemString];
   
   return( converted);
}


- (NSString *) stringWithFileSystemRepresentationUTF16:(mulle_utf16_t *) s_utf16
                                                length:(NSUInteger) len
{
   NSString   *path;
   NSString   *converted;

   if( ! s_utf16)
      return( nil);

   path      = [NSString mulleStringWithUTF16String:s_utf16];
   converted = [path mulleUnixFileSystemString];

   return( converted);
}


- (NSString *) pathContentOfSymbolicLinkAtPath:(NSString *) path
{
   // Windows doesn't support symlinks in the same way as Unix
   // Return nil to indicate no symlink
   return( nil);
}


- (BOOL) changeCurrentDirectoryPath:(NSString *) path
{
   BOOL            result;
   mulle_utf16_t   *s_utf16;

   MulleObjCSetWindowsErrorDomain();

   s_utf16 = [self fileSystemRepresentationUTF16WithPath:path];
   if( ! s_utf16)
      return( NO);

   result = SetCurrentDirectoryW( s_utf16);

   return( result ? YES : NO);
}


- (NSString *) currentDirectoryPath
{
   WCHAR       buf[ MAX_PATH];
   DWORD       len;
   NSString    *path;

   MulleObjCSetWindowsErrorDomain();

   len = GetCurrentDirectoryW( MAX_PATH, buf);
   if( ! len)
      return( nil);

   // len is the number of characters excluding null terminator
   path = [[[NSString alloc] mulleInitWithUTF16Characters:(mulle_utf16_t *) buf
                                                   length:len] autorelease];
   // Convert Windows path to Unix format
   path = [path mulleUnixFileSystemString];
   return( path);
}



- (BOOL) fileExistsAtPath:(NSString *) path
{
   DWORD            attrs;
   mulle_utf16_t   *s_utf16;

   MulleObjCSetWindowsErrorDomain();

   s_utf16 = [self fileSystemRepresentationUTF16WithPath:path];
   if( ! s_utf16 || ! *s_utf16)
      return( NO);

   attrs = GetFileAttributesW( s_utf16);

   return( attrs != INVALID_FILE_ATTRIBUTES ? YES : NO);
}


- (BOOL) fileExistsAtPath:(NSString *) path
              isDirectory:(BOOL *) isDir
{
   DWORD            attrs;
   BOOL             dummy;
   mulle_utf16_t   *s_utf16;

   MulleObjCSetWindowsErrorDomain();

   if( ! isDir)
      isDir = &dummy;

   s_utf16 = [self fileSystemRepresentationUTF16WithPath:path];
   if( ! s_utf16)
   {
      *isDir = NO;
      return( NO);
   }

   attrs = GetFileAttributesW( s_utf16);

   if( attrs == INVALID_FILE_ATTRIBUTES)
   {
      *isDir = NO;
      return( NO);
   }

   *isDir = (attrs & FILE_ATTRIBUTE_DIRECTORY) ? YES : NO;
   return( YES);
}


- (BOOL) isReadableFileAtPath:(NSString *) path
{
   DWORD            attrs;
   mulle_utf16_t   *s_utf16;

   MulleObjCSetWindowsErrorDomain();

   s_utf16 = [self fileSystemRepresentationUTF16WithPath:path];
   if( ! s_utf16)
      return( NO);

   attrs = GetFileAttributesW( s_utf16);

   return( attrs != INVALID_FILE_ATTRIBUTES ? YES : NO);
}


- (BOOL) isWritableFileAtPath:(NSString *) path
{
   DWORD            attrs;
   mulle_utf16_t   *s_utf16;

   MulleObjCSetWindowsErrorDomain();

   s_utf16 = [self fileSystemRepresentationUTF16WithPath:path];
   if( ! s_utf16)
      return( NO);

   attrs = GetFileAttributesW( s_utf16);

   if( attrs == INVALID_FILE_ATTRIBUTES)
      return( NO);

   return( (attrs & FILE_ATTRIBUTE_READONLY) ? NO : YES);
}


- (BOOL) isDeletableFileAtPath:(NSString *) path
{
   return( [self isWritableFileAtPath:path]);
}


- (BOOL) isExecutableFileAtPath:(NSString *) path
{
   NSString   *ext;

   MulleObjCSetWindowsErrorDomain();

   if( ! [self fileExistsAtPath:path])
      return( NO);

   ext = [[path pathExtension] lowercaseString];
   return( [ext isEqualToString:@"exe"] || 
           [ext isEqualToString:@"bat"] || 
           [ext isEqualToString:@"cmd"] ||
           [ext isEqualToString:@"com"]);
}


- (int) _createDirectoryAtPath:(NSString *) path
                    attributes:(NSDictionary *) attributes
{
   BOOL             result;
   mulle_utf16_t   *s_utf16;

   s_utf16 = [self fileSystemRepresentationUTF16WithPath:path];
   if( ! s_utf16)
      return( -1);

   result = CreateDirectoryW( s_utf16, NULL);

   if( result)
      return( 0);

   switch( GetLastError())
   {
   case ERROR_ALREADY_EXISTS : return( EEXIST);
   case ERROR_PATH_NOT_FOUND : return( ENOENT);
   default                   : return( -1);
   }
}


- (BOOL) createDirectoryAtPath:(NSString *) path
   withIntermediateDirectories:(BOOL) createIntermediates
                    attributes:(NSDictionary *) attributes
                         error:(NSError **) error
{
   NSArray          *components;
   NSMutableArray   *subComponents;
   NSString         *subpath;
   NSUInteger       i, n;
   int              rc;

   MulleObjCSetWindowsErrorDomain();

   rc = [self _createDirectoryAtPath:path
                          attributes:attributes];
   if( ! rc)
      return( YES);

   if( rc != ENOENT)
      return( NO);

   if( ! createIntermediates)
      return( NO);

   subComponents = [NSMutableArray array];
   components    = [path pathComponents];
   n             = [components count];

   for( i = 0; i < n; i++)
   {
      [subComponents addObject:[components objectAtIndex:i]];
      subpath = [NSString pathWithComponents:subComponents];

      rc = [self _createDirectoryAtPath:subpath
                             attributes:attributes];
      if( rc == EEXIST)
         break;

      if( rc)
         return( NO);
   }

   return( YES);
}


- (BOOL) _removeFileAtPath:(NSString *) path
{
   BOOL             result;
   mulle_utf16_t   *s_utf16;

   s_utf16 = [self fileSystemRepresentationUTF16WithPath:path];
   if( ! s_utf16)
      return( NO);

   result = DeleteFileW( s_utf16);

   return( result ? YES : NO);
}


- (BOOL) _removeEmptyDirectoryItemAtPath:(NSString *) path
{
   BOOL             result;
   mulle_utf16_t   *s_utf16;

   s_utf16 = [self fileSystemRepresentationUTF16WithPath:path];
   if( ! s_utf16)
      return( NO);

   result = RemoveDirectoryW( s_utf16);

   return( result ? YES : NO);
}


- (NSArray *) directoryContentsAtPath:(NSString *) path
{
   WIN32_FIND_DATAW   findData;
   HANDLE             hFind;
   NSMutableArray     *array;
   NSString           *searchPath;
   NSString           *filename;
   mulle_utf16_t      *s_utf16;

   MulleObjCSetWindowsErrorDomain();

   searchPath = [path stringByAppendingPathComponent:@"*"];
   s_utf16    = [self fileSystemRepresentationUTF16WithPath:searchPath];
   if( ! s_utf16)
      return( nil);

   array = [NSMutableArray array];
   hFind = FindFirstFileW( s_utf16, &findData);

   if( hFind == INVALID_HANDLE_VALUE)
      return( nil);

   do
   {
      if( findData.cFileName[ 0] == '.')
      {
         if( ! findData.cFileName[ 1])
            continue;
         if( findData.cFileName[ 1] == '.' && ! findData.cFileName[ 2])
            continue;
         if( findData.cFileName[ 1] == '_')
            continue;
      }

      filename = [self stringWithFileSystemRepresentationUTF16:findData.cFileName
                                                        length:wcslen( findData.cFileName)];
      [array addObject:filename];
   }
   while( FindNextFileW( hFind, &findData));

   FindClose( hFind);

   return( array);
}


@end

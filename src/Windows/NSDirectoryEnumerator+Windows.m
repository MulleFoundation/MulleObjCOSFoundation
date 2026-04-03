//
//  NSDirectoryEnumerator+Windows.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 24.01.26
//  Copyright © 2026 Mulle kybernetiK. All rights reserved.
//
#import "import-private.h"

#import <MulleObjCOSBaseFoundation/NSFileManager-Private.h>

// other files in this library
#import "NSErrorWindows.h"
#import "NSFileManager+Windows.h"

// std-c and dependencies
#include <windows.h>


@implementation NSDirectoryEnumerator( Windows)

- (instancetype) initWithFileManager:(NSFileManager *) manager
                            rootPath:(NSString *) root
                       inheritedPath:(NSString *) inherited
{
   NSString         *path;
   NSString         *searchPath;
   mulle_utf16_t    *s_utf16;
   HANDLE           hFind;
   WIN32_FIND_DATAW findData;

   if( ! root)
      return( nil);

   [super init];

   path       = inherited ? [root stringByAppendingPathComponent:inherited] : root;
   searchPath = [path stringByAppendingPathComponent:@"*"];
   
   s_utf16 = [manager fileSystemRepresentationUTF16WithPath:searchPath];
   if( ! s_utf16)
   {
      [self release];
      return( nil);
   }

   hFind = FindFirstFileW( s_utf16, &findData);

   if( hFind == INVALID_HANDLE_VALUE)
   {
      MulleObjCSetWindowsErrorDomain();
      [self release];
      return( nil);
   }

   _dir           = hFind;
   _manager       = [manager retain];
   _rootPath      = [root copy];
   
   _inheritedPath = [[manager stringWithFileSystemRepresentationUTF16:findData.cFileName
                                                                length:wcslen( findData.cFileName)] retain];
   
   _isDirectory = (findData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) ? 1 : 0;

   return( self);
}


- (NSString *) _nextEntry:(int *) is_dir
{
   WIN32_FIND_DATAW   findData;
   HANDLE             hFind;
   NSString           *filename;
   BOOL               result;

   MulleObjCSetWindowsErrorDomain();

   hFind = (HANDLE) _dir;
   if( hFind == INVALID_HANDLE_VALUE)
      return( nil);

   *is_dir = _MulleObjCIsMaybeADirectory;

   if( _inheritedPath)
   {
      filename       = [_inheritedPath autorelease];
      _inheritedPath = nil;
      
      if( _isDirectory)
         *is_dir = _MulleObjCIsADirectory;
      else
         *is_dir = _MulleObjCIsNotADirectory;
      
      switch( [_manager _isValidDirectoryContentsFilenameAsCString:(char *) [filename UTF8String]])
      {
      case _MulleObjCFilenameIsDot:
      case _MulleObjCFilenameIsDotDot:
      case _MulleObjCFilenameIsNoFile:
         goto retry;
      default:
         return( filename);
      }
   }

retry:
   result = FindNextFileW( hFind, &findData);
   if( ! result)
   {
      if( GetLastError() == ERROR_NO_MORE_FILES)
         return( nil);
      return( nil);
   }

   filename = [[_manager stringWithFileSystemRepresentationUTF16:findData.cFileName
                                                          length:wcslen( findData.cFileName)] autorelease];

   switch( [_manager _isValidDirectoryContentsFilenameAsCString:(char *) [filename UTF8String]])
   {
   case _MulleObjCFilenameIsDot:
   case _MulleObjCFilenameIsDotDot:
   case _MulleObjCFilenameIsNoFile:
      goto retry;
   default:
      break;
   }

   if( findData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
      *is_dir = _MulleObjCIsADirectory;
   else
      *is_dir = _MulleObjCIsNotADirectory;

   return( filename);
}


- (void) _close
{
   HANDLE   hFind;

   hFind = (HANDLE) _dir;
   if( hFind && hFind != INVALID_HANDLE_VALUE)
   {
      FindClose( hFind);
      _dir = NULL;
   }
}

@end

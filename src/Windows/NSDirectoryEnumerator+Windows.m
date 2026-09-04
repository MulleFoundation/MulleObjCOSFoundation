//
//  NSDirectoryEnumerator+Windows.m
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
   _inheritedPath = [inherited copy];

   return( self);
}


- (NSString *) _nextEntry:(int *) is_dir
{
   WIN32_FIND_DATAW   findData;
   HANDLE             hFind;
   NSString           *filename;

   MulleObjCSetWindowsErrorDomain();

   hFind = (HANDLE) _dir;
   if( hFind == INVALID_HANDLE_VALUE)
      return( nil);

   *is_dir = _MulleObjCIsMaybeADirectory;

retry:
   if( ! FindNextFileW( hFind, &findData))
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

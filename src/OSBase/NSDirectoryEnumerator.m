//
//  NSDirectoryEnumerator.m
//  MulleObjCOSFoundation
//
//  Copyright (c) 2020 Nat! - Mulle kybernetiK.
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
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "NSDirectoryEnumerator.h"

// other files in this library
#import "NSFileManager.h"
#import "NSFileManager-Private.h"
#import "NSString+OSBase.h"
// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#ifndef _WIN32
# include <dirent.h>
# include <sys/stat.h>
#endif


#pragma clang diagnostic ignored  "-Wswitch"


@implementation NSDirectoryEnumerator

- (instancetype) initWithFileManager:(NSFileManager *) manager
                           directory:(NSString *) path
{
   return( [self initWithFileManager:manager
                            rootPath:path
                       inheritedPath:nil]);
}


- (void) dealloc
{
   [self _close];

   [_child release];  // sic! never exposed

   [_manager release];
   [_rootPath release];
   [_inheritedPath release];
   [_currentObjectRelativePath release];

   [super dealloc];
}


- (NSDictionary *) directoryAttributes
{
   return( [_manager fileAttributesAtPath:_rootPath
                             traverseLink:YES]);
}


- (NSDictionary *) fileAttributes
{
   NSString  *path;

   path = [_rootPath stringByAppendingPathComponent:_currentEnumerationRelativePath_];
   return( [_manager fileSystemAttributesAtPath:path]);
}


- (NSUInteger) level
{
   return( [[_inheritedPath componentsSeparatedByString:NSFilePathComponentSeparator] count]);
}


// The search is shallow and therefore does not return the contents of any
// subdirectories. This returned array does not contain strings for the current
// directory (“.”), parent directory (“..”), or resource forks (begin with “._”)
// and does not traverse symbolic links.
//
// Expected output
// Briefe/Bewerbung/Alternativ/lebenslauf.doc
// Briefe/Bewerbung/Lebenslauf.doc
//
- (id) nextObject
{
   NSString                          *filename;
   NSString                          *absolutePath;
   id                                obj;
   enum _MulleObjCIsDirectoryState   state;
   BOOL                              is_dir2;

   if( ! _dir)
      return( nil);

retry:
   if( _isDirectory && ! _child)
      _child = [[NSDirectoryEnumerator alloc] initWithFileManager:_manager
                                                         rootPath:_rootPath
                                                    inheritedPath:_currentObjectRelativePath];
   if( _child)
   {
      obj = [_child nextObject];
      if( obj)
      {
         _currentEnumerationRelativePath_ = obj;
         return( _currentEnumerationRelativePath_);
      }

      [_child release];  // danger  _currentEnumerationRelativePath may be dead
      _child = nil;
   }

   [_currentObjectRelativePath autorelease];

   _currentObjectRelativePath       = nil;
   _currentEnumerationRelativePath_ = nil;
   _isDirectory                     = NO;

retry_file:
   filename = [self _nextEntry:&state];
   if( ! filename)
   {
      [self _close];
      return( nil);
   }

   if( _inheritedPath)
   {
      filename = [_inheritedPath stringByAppendingPathComponent:filename];
   }

   [_currentObjectRelativePath release];
   _currentObjectRelativePath = [filename copy];

   switch( state)
   {
   case _MulleObjCIsMaybeADirectory :
      absolutePath = [_rootPath stringByAppendingPathComponent:filename];
      if( ! [_manager fileExistsAtPath:absolutePath
                           isDirectory:&is_dir2])
      {
         mulle_fprintf( stderr, "Directory entry \"%@\" vanished during enumeration, hmm", _currentObjectRelativePath);
         goto retry_file; // gone now ?
      }
      if( is_dir2)
      {
   case _MulleObjCIsADirectory :
         _isDirectory = YES;
         goto retry;
      }
   }

   _currentEnumerationRelativePath_ = _currentObjectRelativePath;
   return( _currentEnumerationRelativePath_);
}


- (void) skipDescendants
{
   _isDirectory = NO;
}


- (void) skipDescendents
{
   _isDirectory = NO;
}

@end


//
//  NSDirectoryEnumerator+Posix.m
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

// other files in this library
#import <MulleObjCOSBaseFoundation/NSFileManager-Private.h>

// other libraries of MulleObjCPosixFoundation
#import "NSError+Posix.h"

// std-c and dependencies
#include <dirent.h>
#include <sys/stat.h>



@implementation NSDirectoryEnumerator (Posix)

- (instancetype) initWithFileManager:(NSFileManager *) manager
                            rootPath:(NSString *) root
                       inheritedPath:(NSString *) inherited
{
   NSString   *path;
   char       *s;

   // According to the Apple Developer Documentation, if rootPath is nil,
   // the method returns nil. This is because rootPath is the path to the
   // root directory that you want to enumerate, and without it, the method
   // doesn't know where to start.

   if( ! root)
      return( nil);

   [super init];

   // inheritedPath is a path that will be appended to the rootPath, its
   // basically the subdirectories part
   // and if it's nil, there's nothing to prepend
   path = inherited ? [root stringByAppendingPathComponent:inherited] : root;
   s    = [path fileSystemRepresentation];
   _dir = opendir( s);
   if( ! _dir)
   {
      MulleObjCSetPosixErrorDomain();

      [self release];
      return( nil);
   }

   _manager       = [manager retain];
   _rootPath      = [root copy];
   _inheritedPath = [inherited copy];

   return( self);
}


- (NSString *) _nextEntry:(int *) is_dir
{
   struct dirent    *entry;

   MulleObjCSetPosixErrorDomain();

   *is_dir = _MulleObjCIsMaybeADirectory;
retry:
   entry = readdir( _dir);
   if( ! entry)
      return( nil);

   switch( [_manager _isValidDirectoryContentsFilenameAsCString:entry->d_name])
   {
   case _MulleObjCFilenameIsDot    :
   case _MulleObjCFilenameIsDotDot :
   case _MulleObjCFilenameIsNoFile : goto retry;
   default                         : break;
   }

   return( [[[NSString alloc] initWithCString:entry->d_name] autorelease]);
}


- (void) _close
{
   if( _dir)
   {
      closedir( _dir);
      _dir = 0;
   }
}


@end

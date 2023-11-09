//
//  NSDirectoryEnumerator+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

// define, that make things POSIXly
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

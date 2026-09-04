//
//  NSFileManager+Darwin.m
//  MulleObjCOSFoundation
//
//  Copyright (c) 2016 Nat! - Mulle kybernetiK.
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
#define _DARWIN_C_SOURCE

#import "import-private.h"

// other files in this library

// std-c and dependencies
#include <sys/stat.h>
#include <sys/time.h>
#include <dirent.h>
#include <float.h>
#include <unistd.h>


@implementation NSFileManager (Darwin)

@dependency NSFileManager( Posix);


//
// is the idea, that NSFileManager can manage various filesystems
// and convert to the proper encoding for each ?
//
- (char *) fileSystemRepresentationWithPath:(NSString *) path
{
   if( ! [path length] || ! [path canBeConvertedToEncoding:[NSString defaultCStringEncoding]])
   {
      errno = EINVAL;
      return( NULL);
   }

   return( [path cString]);  // assume
}


- (NSString *) stringWithFileSystemRepresentation:(char *) s
                                           length:(NSUInteger) len
{
   return( [NSString stringWithCString:s
                                length:len]);
}


// use void * to get around different type encodings in signature
- (struct timespec) _getCTimeFromStat:(void *) aStat
{
   struct stat   *stat = aStat;

   return( stat->st_ctimespec);
}


// use void * to get around different type encodings in signature
- (struct timespec) _getMTimeFromStat:(void *) aStat
{
   struct stat   *stat = aStat;

   return( stat->st_mtimespec);
}


@end

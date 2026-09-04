//
//  NSString+OSBase.h
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
#import "import.h"


@interface NSString( OSBase)

+ (instancetype) pathWithComponents:(NSArray *) components;

- (BOOL) isAbsolutePath;
- (NSString *) lastPathComponent;
- (NSString *) pathExtension;
- (NSString *) stringByAppendingPathComponent:(NSString *) component;
- (NSString *) stringByAppendingPathExtension:(NSString *) extension;
- (NSString *) stringByDeletingLastPathComponent;
- (NSString *) stringByDeletingPathExtension;
- (NSString *) stringByExpandingTildeInPath;
- (NSString *) stringByResolvingSymlinksInPath;
- (NSString *) stringByStandardizingPath;

- (NSArray *) pathComponents;
- (NSString *) initWithPathComponents:(NSArray *) components;

- (char *) fileSystemRepresentation;
- (BOOL) getFileSystemRepresentation:(char *) buf
                           maxLength:(NSUInteger) max;

+ (instancetype) stringWithContentsOfFile:(NSString *) path;

- (NSUInteger) completePathIntoString:(NSString **) outputName
                        caseSensitive:(BOOL) flag
                     matchesIntoArray:(NSArray **) outputArray
                          filterTypes:(NSArray *) filterTypes;

#pragma mark - mark mulle additions

//
// Because the MulleFoundation only accepts properly encoded strings
// and NSData, it is impossible to load in text files, where maybe just a single
// byte has been corrupted.
//
// So these methods will try to determine the correct encoding (as
// initWithContentsOfFile : does) and  will replace offending characters with
// the '?' character
//
- (instancetype) mulleInitWithLossyContentsOfFile:(NSString *) path;
+ (instancetype) mulleStringWithLossyContentsOfFile:(NSString *) path;

- (NSString *) mulleStringBySimplifyingPath;  // just removes /./ and /../

- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag;

- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag
            encoding:(NSStringEncoding) encoding
               error:(NSError **) error;
@end


@interface NSString( OSBaseFuture) < MulleObjCFuture>

- (instancetype) initWithContentsOfFile:(NSString *) path;

@end


//
// Convert between Unix and Windows path separators.
// On Posix/Linux, mulleUnixFileSystemString returns self.
// On Windows, mulleWindowsFileSystemString returns self.
//
@interface NSString( FileSystemString)

- (NSString *) mulleUnixFileSystemString;
- (NSString *) mulleWindowsFileSystemString;

@end



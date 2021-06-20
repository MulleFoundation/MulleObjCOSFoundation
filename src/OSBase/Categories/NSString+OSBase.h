/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSString+PosixPathHandling.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
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


@interface NSString( OSBaseFuture)

- (instancetype) initWithContentsOfFile:(NSString *) path;

@end

extern NSString  *NSFilePathComponentSeparator;
extern NSString  *NSFilePathExtensionSeparator;


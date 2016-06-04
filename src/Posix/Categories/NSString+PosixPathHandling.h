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
#import <MulleObjCFoundation/MulleObjCFoundation.h>


@interface NSString( PosixPathHandling)

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

#pragma mark -
#pragma mark mulle additions

- (NSString *) _stringBySimplifyingPath;  // just removes /./ and /../
                           
@end

extern NSString  *NSFilePathComponentSeparator;
extern NSString  *NSFilePathExtensionSeparator;


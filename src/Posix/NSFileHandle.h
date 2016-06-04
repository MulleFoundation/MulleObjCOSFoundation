/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSFileHandle.h is a part of MulleFoundation
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


@class NSData;


@interface NSFileHandle : NSObject
{
   int   _fd;
   void  (*_closer)( int);
}

+ (id) fileHandleForReadingAtPath:(NSString *) path;
+ (id) fileHandleForWritingAtPath:(NSString *) path;
+ (id) fileHandleForUpdatingAtPath:(NSString *) path;

+ (id) fileHandleWithStandardError;
+ (id) fileHandleWithStandardInput;
+ (id) fileHandleWithStandardOutput;
+ (id) fileHandleWithNullDevice;

- (id) initWithFileDescriptor:(int) fd;
- (id) initWithFileDescriptor:(int) fd
               closeOnDealloc:(BOOL) flag;

- (NSData *) availableData;
- (NSData *) readDataToEndOfFile;
- (NSData *) readDataOfLength:(NSUInteger) length;

- (unsigned long long) offsetInFile;
- (void) seekToEndOfFile;
- (void) seekToFileOffset:(unsigned long long) offset;
- (void) closeFile;
- (void) synchronizeFile;
- (void) truncateFileAtOffset:(unsigned long long) offset;

- (void) writeData:(NSData *) data;

- (int) fileDescriptor;

//+ (id) fileHandleForReadingFromURL:error:
//+ (id) fileHandleForUpdatingURL:error:
//+ (id) fileHandleForWritingToURL:error:

- (int) _fileDescriptorForReading;
- (int) _fileDescriptorForWriting;

@end


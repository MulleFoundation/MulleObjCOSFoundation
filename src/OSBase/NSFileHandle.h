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
#import "import.h"


@class NSData;


MULLE_OBJC_OSBASE_FOUNDATION_GLOBAL
NSString  *NSFileHandleOperationException;

enum NSFileHandleStateBit
{
   NSFileHandleStateEOF   = 1,
   NSFileHandleStatePipe  = 2,
   NSFileHandleStateAgain = 4
};

//
// This class contains the abstract code for a NSFileHandle
// it could be made thread safe with little effort, but a filehandle object
// should only be accessed by a single thread anyway (the underlying file
// descriptor (like 1 for stdout) is a different thing)
//
@interface NSFileHandle : NSObject <MulleObjCInputStream, MulleObjCOutputStream, MulleObjCThreadSafe>
{
   void              *_fd;
   int               (*_closer)( void *); // TODO: use mulle_buffer_stdio_functions ??
   int               _mode;
   int               _closerRval;
   NSUIntegerAtomic  _state;
}
+ (instancetype) fileHandleForReadingAtPath:(NSString *) path;
+ (instancetype) fileHandleForWritingAtPath:(NSString *) path;
+ (instancetype) fileHandleForUpdatingAtPath:(NSString *) path;

+ (instancetype) fileHandleWithNullDevice;

- (instancetype) initWithFileDescriptor:(int) fd;

- (NSData *) availableData;
- (NSData *) readDataToEndOfFile;
- (NSData *) readDataOfLength:(NSUInteger) length;

- (unsigned long long) offsetInFile;
- (unsigned long long) seekToEndOfFile;
- (void) seekToFileOffset:(unsigned long long) offset;
- (void) truncateFileAtOffset:(unsigned long long) offset;

- (void) writeData:(NSData *) data;

- (int) fileDescriptor;


// hackish for pipes
- (int) _fileDescriptorForReading;
- (int) _fileDescriptorForWriting;


// does -finalize
- (void) closeFile;

// mulle addition, if len == -1, it will strlen bytes!!
- (void) mulleWriteBytes:(void *) bytes
                  length:(NSUInteger) len;

- (void) mulleAddToStateBits:(NSUInteger) bits;
- (NSUInteger) mulleGetStateBits;

@end



// these enums are used internally for communicating with the
// subclasses, you don't need them otherwise

enum _MulleObjCOpenMode
{
   _MulleObjCOpenReadOnly  = 0,
   _MulleObjCOpenWriteOnly = 1,
   _MulleObjCOpenReadWrite = 2
};

enum _MulleObjCSeekMode
{
   _MulleObjCSeekCur = 0,
   _MulleObjCSeekSet = 1,
   _MulleObjCSeekEnd = 2
};



@interface NSFileHandle( Subclass)

+ (instancetype) fileHandleWithStandardInput;
+ (instancetype) fileHandleWithStandardOutput;
+ (instancetype) fileHandleWithStandardError;

- (instancetype) initWithFileDescriptor:(int) fd
                         closeOnDealloc:(BOOL) flag;
- (void) closeFile;
- (void) synchronizeFile;


// low level stuff

+ (instancetype) _fileHandleWithPath:(NSString *) path
                      mode:(enum _MulleObjCOpenMode) mode;

- (size_t) _readBytes:(void *) buf
                length:(size_t) len;

- (size_t) _writeBytes:(void *) buf
                length:(size_t) len;

- (unsigned long long) _seek:(unsigned long long) offset
                        mode:(enum _MulleObjCSeekMode) mode;

@end


// is this a mulle addition ?
@interface NSNullDeviceFileHandle : NSFileHandle
@end


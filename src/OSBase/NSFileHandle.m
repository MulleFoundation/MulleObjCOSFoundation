/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSFileHandle.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSFileHandle.h"

#import "NSPageAllocation.h"


// https://developer.apple.com/documentation/foundation/nsfilehandleoperationexception
NSString *NSFileHandleOperationException = @"NSFileHandleOperationException";


@implementation NSNullDeviceFileHandle

- (int) fileDescriptor
{
   return( -1);
}


- (NSData *) availableData
{
   return( [NSData data]);
}


- (NSData *) readDataToEndOfFile
{
   return( [NSData data]);
}


- (NSData *) readDataOfLength:(NSUInteger) length
{
   return( [NSData data]);
}


- (unsigned long long) offsetInFile
{
   return( 0);
}


- (unsigned long long) seekToEndOfFile
{
   return( 0);
}


- (void) seekToFileOffset:(unsigned long long) offset
{
}


- (void) closeFile
{
}


- (void) synchronizeFile
{
}


- (void) truncateFileAtOffset:(unsigned long long) offset
{
}

@end


@implementation NSFileHandle


#pragma mark - open

//
// keep fd in a void pointer, so that a subclass can
// use arbitrary large handles
//
static id   NSInitFileHandle( NSFileHandle *self, void *fd)
{
   self->_fd = fd;
   return( self);
}


- (instancetype) initWithFileDescriptor:(int) fd
{
   return( NSInitFileHandle( self, (void *) (intptr_t) fd));
}


+ (instancetype) fileHandleForReadingAtPath:(NSString *) path
{
   return( [self _fileHandleWithPath:path
                                mode:_MulleObjCOpenReadOnly]);
}


+ (instancetype) fileHandleForWritingAtPath:(NSString *) path
{
   return( [self _fileHandleWithPath:path
                                mode:_MulleObjCOpenWriteOnly]);
}


+ (instancetype) fileHandleForUpdatingAtPath:(NSString *) path
{
   return( [self _fileHandleWithPath:path
                                mode:_MulleObjCOpenReadWrite]);
}


+ (instancetype) fileHandleWithNullDevice
{
   return( [[NSNullDeviceFileHandle new] autorelease]);
}


///
// we basically use -finalize as a thread sync mechanism here, as only
// one thread can be executing close
//
- (void) finalize
{
   if( _closer)
   {
      _closerRval = (*_closer)( _fd);
      if( _closerRval == 0)
         _closer = 0;
      // else, raise or what ?
   }

   [super finalize];
}



#pragma mark - close

- (void) closeFile
{
   [self mullePerformFinalize];
}


- (int) fileDescriptor
{
   return( (int)(intptr_t) _fd);
}


- (int) _fileDescriptorForReading
{
   return( (int)(intptr_t) _fd);
}


- (int) _fileDescriptorForWriting
{
   return( (int)(intptr_t) _fd);
}


#pragma mark - read

//
// if the returned [data length] is < length, then EOF has been reached
// This method raises NSFileHandleOperationException
// if attempts to determine the file-handle type fail or if attempts
// to read from the file or channel fail.
//
static NSData   *readDataOfLength( NSFileHandle *self,
                                   NSUInteger length,
                                   BOOL untilFullOrEOF)
{
   NSMutableData   *data;
   size_t          len;
   size_t          read_len;
   char            *buf;
   char            *start;

   if( ! length || (NSUIntegerAtomicGet( &self->_state) & NSFileHandleStateEOF))
      return( nil);

   data  = [NSMutableData dataWithLength:length];
   start = [data mutableBytes];
   buf   = start;
   len   = length;

   do
   {
      read_len = [self _readBytes:buf
                           length:len];
      if( ! read_len)
         break;

      len -= read_len;
      buf  = &buf[ read_len];
   }
   while( untilFullOrEOF && len);

   [data setLength:buf - start];
   return( data);
}


static NSData   *readAllData( NSFileHandle *self, BOOL untilFullOrEOF)
{
   NSMutableData   *data;
   NSData          *page;
   NSUInteger      length;

   length = NSPageSize();
   data   = [NSMutableData data];
   for(;;)
   {
      page = readDataOfLength( self, length, untilFullOrEOF);
      [data appendData:page];
      if( [page length] < length)
         return( data);
   }
}


- (NSData *) availableData
{
   return( readAllData( self, NO));
}


- (NSData *) readDataToEndOfFile
{
   return( readAllData( self, YES));
}


- (NSData *) readDataOfLength:(NSUInteger) length
{
   return( readDataOfLength( self, length, YES));
}


#pragma mark - write

- (void) writeData:(NSData *) data
{
   [self mulleWriteBytes:[data bytes]
                  length:[data length]];
}


- (void) mulleWriteBytes:(void *) bytes
                  length:(NSUInteger) len
{
   char     *buf = bytes;
   size_t   written;

   if( len == (NSUInteger) -1)
      len = strlen( bytes);

   while( len)
   {
      written = [self _writeBytes:buf
                           length:len];
      if( ! written && (NSUIntegerAtomicGet( &self->_state) & NSFileHandleStateEOF))
         break;

      len -= written;
      buf  = &buf[ written];
   }
}


#pragma mark - seek

- (unsigned long long) offsetInFile
{
   return( (unsigned long long) [self _seek:0
                                       mode:_MulleObjCSeekCur]);
}


- (unsigned long long) seekToEndOfFile
{
   return( [self _seek:0
                  mode:_MulleObjCSeekEnd]);
}


- (void) seekToFileOffset:(unsigned long long) offset
{
   [self _seek:offset
          mode:_MulleObjCSeekSet];
}


- (void) truncateFileAtOffset:(unsigned long long) offset
{
   [self _seek:offset
          mode:_MulleObjCSeekCur]; // TODO: check!
}


- (void) mulleAddToStateBits:(NSUInteger) bits
{
   NSUIntegerAtomicMaskedOr( &self->_state, ~0L, bits);
}


- (NSUInteger) mulleGetStateBits
{
   NSUInteger   state;

   state = NSUIntegerAtomicGet( &self->_state);
   return( state);
}

@end


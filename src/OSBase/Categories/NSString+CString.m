//
//  NSString+CString.m
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
#define _XOPEN_SOURCE 700

#import "NSString+CString.h"

// other files in this library

// std-c and dependencies


@implementation NSString (CString)



+ (instancetype) stringWithCString:(char *) s
{
   return( [[[self alloc] initWithCString:s] autorelease]);
}


+ (instancetype) stringWithCString:(char *) s
                            length:(NSUInteger) len
{
   return( [[[self alloc] initWithCString:s
                                   length:len] autorelease]);
}


- (instancetype) initWithCString:(char *) s
                          length:(NSUInteger) len
{
   return( [self initWithBytes:s
                        length:len
                      encoding:[self _cStringEncoding]]);
}



- (instancetype) initWithCString:(char *) s
{
   return( [self initWithBytes:s
                        length:-1
                      encoding:[self _cStringEncoding]]);
}


- (instancetype) initWithCStringNoCopy:(char *) s
                                length:(NSUInteger) length
                          freeWhenDone:(BOOL) flag
{
   return( [self initWithBytesNoCopy:s
                              length:length
                            encoding:[self _cStringEncoding]
                        freeWhenDone:flag]);
}


- (void) getCString:(char *) bytes
{
   if( ! [self getBytes:bytes
              maxLength:[self cStringLength]
             usedLength:NULL
               encoding:[self _cStringEncoding]
                options:0
                  range:NSRangeMake( 0, -1)
         remainingRange:NULL])
   {
      [NSException raise:@"fail"
                  format:@"fail"];
   }
}


- (void) getCString:(char *) bytes
          maxLength:(NSUInteger) maxLength
{
   NSUInteger   usedLength;

   NSParameterAssert( maxLength);
   if( ! [self getBytes:bytes
              maxLength:maxLength - 1
             usedLength:&usedLength
               encoding:[self _cStringEncoding]
                options:0
                  range:NSRangeMake( 0, -1)
         remainingRange:NULL])
   {
      [NSException raise:@"fail"
                  format:@"fail"];
   }
   bytes[ usedLength] = 0;
}


- (void) getCString:(char *) bytes
          maxLength:(NSUInteger) maxLength
              range:(NSRange) aRange
     remainingRange:(NSRangePointer) leftoverRange
{
   NSUInteger   usedLength;
   NSParameterAssert( maxLength);

   if( ! [self getBytes:bytes
              maxLength:maxLength - 1
             usedLength:&usedLength
               encoding:[self _cStringEncoding]
                options:0
                  range:aRange
         remainingRange:leftoverRange])
   {
      [NSException raise:@"fail"
                  format:@"fail"];
   }
   bytes[ usedLength] = 0;
}


- (void) getCString:(char *) bytes
          maxLength:(NSUInteger) maxLength
           encoding:(NSStringEncoding) encoding
{
   NSUInteger   usedLength;

   NSParameterAssert( maxLength);

   if( ! [self getBytes:bytes
              maxLength:maxLength - 1
             usedLength:&usedLength
               encoding:encoding
                options:0
                  range:NSRangeMake( 0, -1)
         remainingRange:NULL])
   {
      [NSException raise:@"fail"
                  format:@"fail"];
   }
   bytes[ usedLength] = 0;  
}

@end

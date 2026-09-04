//
//  NSString+CString.h
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


//TODO : rename to CStringCharacters where its not known to 
//       be \0 terminated

@interface NSString( CString)

+ (instancetype) stringWithCString:(char *) s;
+ (instancetype) stringWithCString:(char *) s
                            length:(NSUInteger) length;

- (instancetype) initWithCString:(char *) s
                          length:(NSUInteger) len;
- (instancetype) initWithCString:(char *) s;

- (instancetype) initWithCStringNoCopy:(char *) s
                                length:(NSUInteger) length
                          freeWhenDone:(BOOL) flag;

- (void) getCString:(char *) bytes;
- (void) getCString:(char *) bytes
          maxLength:(NSUInteger) maxLength;
- (void) getCString:(char *) bytes
          maxLength:(NSUInteger) maxLength
           encoding:(NSStringEncoding) encoding;
- (void) getCString:(char *) bytes
          maxLength:(NSUInteger) maxLength
              range:(NSRange) aRange
     remainingRange:(NSRangePointer) leftoverRange;

@end



@interface NSString( CStringFuture) < MulleObjCFuture>

- (NSUInteger) cStringLength;

+ (NSStringEncoding) defaultCStringEncoding;
- (NSStringEncoding) _cStringEncoding;
- (char *) cString;
- (NSUInteger) cStringLength;

@end

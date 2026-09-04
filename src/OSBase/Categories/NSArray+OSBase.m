//
//  NSArray+OSBase.m
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
#import "NSArray+OSBase.h"

// other files in this library
#import "NSData+OSBase.h"

// std-c and dependencies


@interface NSObject( Private)

- (BOOL) __isNSArray;
- (BOOL) __isNSMutableArray;

@end


@implementation NSArray( OSBase)

+ (instancetype) arrayWithContentsOfFile:(NSString *) path
{
   return( [[[self alloc] initWithContentsOfFile:path] autorelease]);
}


- (instancetype) initWithContentsOfFile:(NSString *) path
{
   NSData                            *data;
   id                                plist;
   NSPropertyListMutabilityOptions   options;
   NSPropertyListFormat              format;
   id                                old;

   options = NSPropertyListImmutable;
   if( [self __isNSMutableArray])
      options = NSPropertyListMutableContainers;

   data   = [NSData dataWithContentsOfFile:path];
   format = NSPropertyListOpenStepFormat;
   plist  = [NSPropertyListSerialization propertyListFromData:data
                                            mutabilityOption:options
                                                      format:&format
                                            errorDescription:NULL];
   old = self;
   // memo: do not call class methods hereafter
   if( ! [plist __isNSArray])
      self = nil;
   else
      self = [plist retain];
   [old release];
   return( self);
}


- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag
{
   NSString  *error;
   NSData    *data;

   data = [NSPropertyListSerialization dataFromPropertyList:self
                                                     format:NSPropertyListOpenStepFormat
                                           errorDescription:&error];
   return( [data writeToFile:path
                  atomically:flag]);
}

@end

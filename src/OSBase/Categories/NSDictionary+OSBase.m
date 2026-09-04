//
//  NSDictionary+OSBase.m
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

#import "NSDictionary+OSBase.h"

// other files in this library
#import "NSData+OSBase.h"

// std-c and dependencies

@interface NSObject( Private)

- (BOOL) __isNSDictionary;
- (BOOL) __isNSMutableDictionary;

@end


@implementation NSDictionary( OSBase)

+ (instancetype) dictionaryWithContentsOfFile:(NSString *) path
{
   return( [[[self alloc] initWithContentsOfFile:path] autorelease]);
}


- (instancetype) initWithContentsOfFile:(NSString *) path
{
   NSData                            *data;
   NSPropertyListMutabilityOptions   options;
   id                                old;

   options = NSPropertyListImmutable;
   if( [self __isNSMutableDictionary])
      options = NSPropertyListMutableContainers;

   @autoreleasepool
   {
      data = [NSData dataWithContentsOfFile:path];
      old  = self;
      self = [NSPropertyListSerialization propertyListFromData:data
                                              mutabilityOption:options
                                                        format:NULL
                                              errorDescription:NULL];
      [old release];
      [self retain];
   }

   if( ! [self __isNSDictionary])
   {
      [self release];
      return( nil);
   }
   return( self);
}


- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag
{
   NSString  *error;
   NSData    *data;
   BOOL      rval;

   @autoreleasepool
   {
      data = [NSPropertyListSerialization dataFromPropertyList:self
                                                        format:NSPropertyListOpenStepFormat
                                              errorDescription:&error];
      rval = [data writeToFile:path
                    atomically:flag];
   }
   return( rval);
}

@end

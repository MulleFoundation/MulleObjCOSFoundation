//
//  NSFileHandle+NSRunLoop.m
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
#import "NSFileHandle+NSRunLoop.h"

#import "NSRunLoop.h"
#import "NSRunLoop-Private.h"

#import "NSPageAllocation.h"


MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString  *NSFileHandleReadCompletionNotification = @"NSFileHandleReadCompletionNotification";

// why should I put this into the info dict again ?
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString  *NSFileHandleNotificationFileHandleItem = @"fileHandle";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString  *NSFileHandleNotificationDataItem       = @"data";

//
// we don't dot these yet, or maybe never because file reading with callbacks
// is just not very nice
//
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString *NSFileHandleConnectionAcceptedNotification        = @"NSFileHandleConnectionAcceptedNotification";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString *NSFileHandleDataAvailableNotification             = @"NSFileHandleDataAvailableNotification";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString *NSFileHandleReadToEndOfFileCompletionNotification = @"NSFileHandleReadToEndOfFileCompletionNotification";


@interface NSFileHandle( _NSFileDescriptor)  < _NSFileDescriptor>

- (void) _notifyWithRunLoop:(NSRunLoop *) runloop;

@end


@implementation NSFileHandle( _NSFileDescriptor)

// the runloop notifies us, that there is stuff to read
- (void) _notifyWithRunLoop:(NSRunLoop *) runloop
{
   MULLE_C_UNUSED( runloop);
   NSData         *data;
   NSDictionary   *info;

   data = [self availableData];
   info = [NSDictionary dictionaryWithObject:data
                                      forKey:NSFileHandleNotificationDataItem];
   [[NSNotificationCenter defaultCenter]
    postNotificationName:NSFileHandleReadCompletionNotification
                  object:self
                userInfo:info];
}

@end


@implementation NSFileHandle( NSRunLoop)

- (void) readInBackgroundAndNotify
{
   [[NSRunLoop currentRunLoop] _addObject:self
                                  forMode:NSDefaultRunLoopMode];
}


- (void) readInBackgroundAndNotifyForModes:(NSArray *) modes
{
   NSRunLoop      *runloop;
   NSRunLoopMode   modeName;

   runloop = [NSRunLoop currentRunLoop];
   for( modeName in modes)
      [runloop _addObject:self
                  forMode:modeName];
}

@end


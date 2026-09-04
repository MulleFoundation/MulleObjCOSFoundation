//
//  NSTimer+NSRunLoop.m
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
#import "NSTimer+NSRunLoop.h"

#import "NSRunLoop.h"
#import "NSRunLoop-Private.h"


@implementation NSTimer( NSRunLoop)


+ (NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval) timeInterval
                                      target:(id) target
                                    selector:(SEL) selector
                                    userInfo:(id) userInfo
                                     repeats:(BOOL) repeats
{
   NSTimer   *timer;

   timer = [self timerWithTimeInterval:timeInterval
                                target:target
                              selector:selector
                              userInfo:userInfo
                               repeats:repeats];
   [[NSRunLoop currentRunLoop] addTimer:timer
                                forMode:NSDefaultRunLoopMode];
   return( timer);
}


+ (NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval) timeInterval
                                  invocation:(NSInvocation *) invocation
                                     repeats:(BOOL) repeats
{
   NSTimer   *timer;

   timer = [self timerWithTimeInterval:timeInterval
                            invocation:invocation
                               repeats:repeats];
   [[NSRunLoop currentRunLoop] addTimer:timer
                                forMode:NSDefaultRunLoopMode];
   return( timer);
}


// the whole NSTimer/NSRunLoop interface is strange and crappy
// there is no "removeTimer" on NSRunLoop but only this.
// Also the timer may "invalidate" when the NSRunLoop is no longer
// around (due to autoreleasepool order)
- (void) invalidate
{
   [[NSRunLoop mulleCurrentRunLoop] _removeTimer:self];

   [self->_o.target autorelease];
   self->_o.target = nil;
   [self->_userInfo autorelease];
   self->_userInfo = nil;
   self->_selector = 0;
   self->_callback = NULL;
}

@end


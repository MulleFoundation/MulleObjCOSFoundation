//
//  NSObject+NSRunLoop.m
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
#import "NSObject+NSRunLoop.h"

#import "import-private.h"

#import "NSRunLoop.h"
#import "NSRunLoop-Private.h"


@implementation NSObject( NSRunLoop)

- (void) performSelector:(SEL) selector
              withObject:(id) argument
              afterDelay:(NSTimeInterval) delay
                 inModes:(NSArray *) modes
{
   NSRunLoopMode   modeName;
   NSRunLoop       *runLoop;
   NSTimer         *timer;

   runLoop = [NSRunLoop currentRunLoop];
   for( modeName in modes)
   {
      timer = [[[NSTimer alloc] mulleInitWithRelativeTimeInterval:delay
                                                   repeatInterval:0.0
                                                           target:self
                                                        selector:selector
                                                        userInfo:argument
                                      fireUsesUserInfoAsArgument:YES] autorelease];
      [runLoop addTimer:timer
                forMode:modeName];
   }
}


- (void) performSelector:(SEL) selector
              withObject:(id) argument
              afterDelay:(NSTimeInterval) delay
{
   NSTimer    *timer;
   NSRunLoop  *runLoop;

   timer = [[[NSTimer alloc] mulleInitWithRelativeTimeInterval:delay
                                                repeatInterval:0.0
                                                        target:self
                                                     selector:selector
                                                     userInfo:argument
                                   fireUsesUserInfoAsArgument:YES] autorelease];
   runLoop = [NSRunLoop currentRunLoop];
   [runLoop addTimer:timer
             forMode:NSDefaultRunLoopMode];
}


+ (void) cancelPreviousPerformRequestsWithTarget:(id) target
                                        selector:(SEL) selector
                                          object:(id) argument
{
   [[NSRunLoop currentRunLoop] _removeTimersWithTarget:target
                                              selector:selector
                                              argument:argument];

}


+ (void) cancelPreviousPerformRequestsWithTarget:(id) target
{
   [[NSRunLoop currentRunLoop] _removeTimersWithTarget:target];
}

@end

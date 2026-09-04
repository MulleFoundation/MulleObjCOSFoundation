//
//  NSTask+BSD.m
//  MulleObjCOSFoundation
//
//  Copyright (c) 2016 Nat! - Mulle kybernetiK.
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
#import "import-private.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation
#import <MulleObjCOSBaseFoundation/NSTask-Private.h>

// std-c and dependencies
#include <signal.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>


@implementation NSTask( BSD)

@dependency NSTask( Posix);


- (void) _signal:(int) a_signal
{
   switch( _status)
   {
      default :
         MulleObjCThrowInternalInconsistencyException( @"task not started");
         break;

      case _NSTaskIsPresumablyRunning :
         NSParameterAssert( _pid);
         kill( _pid, a_signal);

      case _NSTaskHasTerminated :
         break;
   }
}



- (void) terminate
{
   [self _signal:SIGTERM];
}


- (void) interrupt
{
   [self _signal:SIGINT];
}


- (BOOL) suspend
{
   [self _signal:SIGSTOP];
   return( YES);
}


- (BOOL) resume
{
   [self _signal:SIGCONT];
   return( YES);
}


- (NSTaskTerminationReason) terminationReason
{
   switch( _status)
   {
      default :
         MulleObjCThrowInternalInconsistencyException( @"task not terminated yet");

      case _NSTaskHasTerminated :
         break;
   }

   if( WIFEXITED( _terminationStatus))
      return( NSTaskTerminationReasonExit);
   return( NSTaskTerminationReasonUncaughtSignal);
}

@end

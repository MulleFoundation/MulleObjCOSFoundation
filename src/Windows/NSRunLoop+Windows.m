/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSRunLoop+Windows.m is a part of MulleObjCOSFoundation
 *
 *  Copyright (C) 2024 Mulle kybernetiK.
 *  All rights reserved.
 *
 */

#import "import-private.h"

// other files in this library
#import <MulleObjCOSBaseFoundation/NSRunLoop-Private.h>
#import <MulleObjCTimeFoundation/NSDate.h>

// Windows headers
#include <windows.h>


struct windows_mode
{
   HANDLE   *handles;
   int      count;
   int      capacity;
};


@implementation NSRunLoop( Windows)

- (void) _finalizeWindows:(struct windows_mode *) ctxt
{
   if( ctxt->handles)
      MulleObjCInstanceDeallocateMemory( self, ctxt->handles);
}


- (void) _initializeRunLoopMode:(struct MulleRunLoopMode *) mode
{
   struct windows_mode   *ctxt;

   ctxt = MulleObjCInstanceAllocateMemory( self, sizeof( struct windows_mode));
   memset( ctxt, 0, sizeof( struct windows_mode));

   mode->osspecific         = ctxt;
   mode->osspecificFinalize = @selector( _finalizeWindows:);
}


#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wmulle-method-implementation"
- (enum MulleRunLoopInputState) _acceptInputForRunLoopMode:(struct MulleRunLoopMode *) mode
                                                beforeDate:(NSDate *) date
{
   struct windows_mode   *ctxt;
   DWORD                 timeout;
   DWORD                 result;
   NSTimeInterval        interval;
   NSTimeInterval        now;
   NSTimer               *firstTimer;

   if( ! mode)
      return( MulleRunLoopNoTimersOrInputLeft);

   ctxt = mode->osspecific;
   if( ! ctxt)
   {
      [self _initializeRunLoopMode:mode];
      ctxt = mode->osspecific;
   }

   // Send messages first
   [self _sendMessagesOfRunLoopMode:mode];

loop:
   // Fire timers
   now = [NSDate timeIntervalSinceReferenceDate];
   [self _fireTimersOfRunLoopMode:mode timeInterval:now];

   // Calculate timeout
   firstTimer = nil;
   if( ! date)
      timeout = INFINITE;
   else
   {
      interval = [date timeIntervalSinceReferenceDate] - now;
      
      if( interval < 0)
         timeout = 0;
      else
         timeout = (DWORD) (interval * 1000);  // Convert to milliseconds
      
      // Check if we have a timer that fires before the date
      firstTimer = [self _firstTimerToFireOfRunLoopMode:mode];
      if( firstTimer)
      {
         NSTimeInterval   fireInterval;
         DWORD            fireTimeout;
         
         fireInterval = [[firstTimer fireDate] timeIntervalSinceReferenceDate] - now;
         if( fireInterval < 0)
            fireTimeout = 0;
         else
            fireTimeout = (DWORD) (fireInterval * 1000);
         
         if( fireTimeout < timeout)
            timeout = fireTimeout;
      }
      else
      {
         // No timer and no handles? Nothing to wait for
         if( ctxt->count == 0)
            return( MulleRunLoopNoTimersOrInputLeft);
      }
   }

   // If no handles, just sleep
   if( ctxt->count == 0)
   {
      if( timeout == 0)
         return( MulleRunLoopInputReceived);
      
      Sleep( timeout == INFINITE ? 100 : timeout);
      
      // If we had a timer, loop back to fire it
      if( firstTimer)
         goto loop;
      
      return( MulleRunLoopTimeout);
   }

   // Wait for handles
   result = WaitForMultipleObjects( ctxt->count, ctxt->handles, FALSE, timeout);

   if( result == WAIT_TIMEOUT)
      return( MulleRunLoopTimeout);

   if( result >= WAIT_OBJECT_0 && result < WAIT_OBJECT_0 + ctxt->count)
      return( MulleRunLoopInputReceived);

   return( MulleRunLoopTimeout);
}
#pragma GCC diagnostic pop

@end

//
//  NSDate+Posix.m
//  MulleObjCOSFoundation
//
//  Copyright (c) 2017 Nat! - Mulle kybernetiK.
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

#import "import-private.h"

// other libraries of MulleObjCPosixFoundation
#include "mulle-posix-tm.h"

// std-c and dependencies

#include <time.h>
#include <sys/time.h>


@implementation NSDate( Posix)


/*
 * Use _MulleObjCConcreteCalendarDate indirectly
 */
- (instancetype) _initWithTM:(struct tm *) tm
                 nanoseconds:(unsigned long long) nanoseconds
                    timeZone:(NSTimeZone *) tz
{
   NSTimeInterval    since1970;

   NSParameterAssert( nanoseconds < 1000000000);

   since1970  = mulle_posix_tm_get_time( tm);
   since1970 += nanoseconds / 1000000000.0;
   since1970 -= [tz mulleSecondsFromGMTForTimeIntervalSince1970:since1970];

   return( [self initWithTimeIntervalSince1970:since1970]);
}


// is it ok to be negative ? i guess so

- (struct timeval) _timevalForSelect
{
   NSTimeInterval   now;
   NSTimeInterval   interval;
   struct timeval   value;

   now      = _NSTimeIntervalNow();
   interval = [self timeIntervalSinceReferenceDate] - now;
   if( interval < 0)
   {
      value.tv_sec  = 0;
      value.tv_usec = 0;
   }
   else
   {
      value.tv_sec  = (long) interval;
      value.tv_usec = (int) ((interval - (NSTimeInterval) value.tv_sec) * 1000000);
   }
   return( value);
}

@end

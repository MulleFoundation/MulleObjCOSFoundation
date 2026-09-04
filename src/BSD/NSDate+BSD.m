//
//  NSDate+BSD.m
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
#import <MulleObjCPosixFoundation/NSDate+Posix-Private.h>
#import <MulleObjCStandardFoundation/_MulleObjCConcreteCalendarDate.h>
#include "mulle-bsd-tm.h"

// std-c and dependencies
#include <time.h>


#if 0
static void   mulle_mini_tm_init_with_time( struct mulle_mini_tm *mini, time_t time)
{
   struct tm   tmp;

   if( ! mini)
      return;

   mulle_bsd_tm_init_with_time( &tmp, time);
   *mini = mulle_posix_tm_get_mini_tm( &tmp);
}
#endif

static time_t    mulle_mini_tm_get_time( struct mulle_mini_tm mini)
{
   struct tm   tmp;

   mulle_bsd_tm_init_with_mini_tm( &tmp, mini);
   return( timegm( &tmp));  // not super sure this doesn't get corrupted
}



@interface NSTimeZone( Posix)

- (NSInteger) mulleSecondsFromGMTForTimeIntervalSince1970:(NSTimeInterval) interval;

@end


@implementation NSDate( BSD)

// NSDate( BSD) overrides -_initWithTM:nanoseconds:timeZone: which is also
// implemented by NSDate( Posix). The runtime requires an explicit load-order
// dependency for the overriding category (mirrors _MulleObjCConcreteCalendarDate
// ( BSD) below).
@dependency NSDate( Posix);

/*
 * Use _MulleObjCConcreteCalendarDate indirectly
 */
- (instancetype) _initWithTM:(struct tm *) tm
                 nanoseconds:(unsigned long long) nanoseconds
                    timeZone:(NSTimeZone *) tz
{
   NSTimeInterval    since1970;

   NSParameterAssert( nanoseconds < 1000000000);

   since1970  = mulle_bsd_tm_get_time( tm);
   since1970 += nanoseconds / 1000000000.0;

   // TODO: use timezone in struct tm if tz is nil ? maybe
   since1970 -= [tz mulleSecondsFromGMTForTimeIntervalSince1970:since1970];

   return( [self initWithTimeIntervalSince1970:since1970]);
}

@end


@implementation _MulleObjCConcreteCalendarDate( BSD)

@dependency _MulleObjCConcreteCalendarDate( Posix);


static void  _MulleObjCConcreteCalendarDateInitBSD( _MulleObjCConcreteCalendarDate *self,
                                                    NSTimeInterval interval,
                                                    NSTimeZone *timeZone)
{
   struct tm   tmp;

   mulle_bsd_tm_init_with_interval1970( &tmp, interval, [timeZone secondsFromGMT]);
   self->_tm.values = mulle_bsd_tm_get_mini_tm( &tmp);
   self->_timeZone  = [timeZone retain];
}


// use specified tz or "GMT" as default
+ (instancetype) newWithTimeIntervalSince1970:(NSTimeInterval) timeInterval
                                      timeZone:(NSTimeZone *) timeZone
{
   _MulleObjCConcreteCalendarDate  *obj;

   if( ! timeZone)
      timeZone = [NSTimeZone mulleGMTTimeZone];  // GMT sic!

   obj = NSAllocateObject( self, 0, NULL);
   _MulleObjCConcreteCalendarDateInitBSD( obj, timeInterval, timeZone);
   return( obj);
}

 // unspecified tz ? use here
+ (instancetype) newWithTimeIntervalSince1970:(NSTimeInterval) timeInterval
{
   _MulleObjCConcreteCalendarDate  *obj;
   NSTimeZone                      *timeZone;

   timeZone = [NSTimeZone defaultTimeZone];

   obj = NSAllocateObject( self, 0, NULL);
   _MulleObjCConcreteCalendarDateInitBSD( obj, timeInterval, timeZone);
   return( obj);
}


- (NSTimeInterval) timeIntervalSince1970
{
   time_t           value;
   NSTimeInterval   interval;

   value     = mulle_mini_tm_get_time( self->_tm.values);
   interval  = (NSTimeInterval) value;
   interval -= [_timeZone mulleSecondsFromGMTForTimeIntervalSince1970:interval];
   return( interval);
}

@end




@implementation NSCalendarDate( BSD)

@dependency NSCalendarDate( Posix);


- (instancetype) _initWithTM:(struct tm *) tm
                 nanoseconds:(unsigned long long) nanoseconds
                    timeZone:(NSTimeZone *) tz
{
   struct mulle_mini_tm   mini;

   mini = mulle_bsd_tm_get_mini_tm( tm);
   return( [self mulleInitWithMiniTM:mini
                            timeZone:tz]);
}


- (NSCalendarDate *) dateByAddingYears:(NSInteger) years
                                months:(NSInteger) months
                                  days:(NSInteger) days
                                 hours:(NSInteger) hours
                               minutes:(NSInteger) minutes
                               seconds:(NSInteger) seconds
{
   struct tm   tmp;

   mulle_bsd_tm_init_with_mini_tm( &tmp, [self mulleMiniTM]);

   tmp.tm_year  += years;
   tmp.tm_mon   += months;
   tmp.tm_mday  += days;

   tmp.tm_hour  += hours;
   tmp.tm_min   += minutes;
   tmp.tm_sec   += seconds;

   return( [[[[self class] alloc] _initWithTM:&tmp
                                  nanoseconds:0
                                     timeZone:[self timeZone]] autorelease]);
}


@end



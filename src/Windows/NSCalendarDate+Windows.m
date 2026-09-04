//
//  NSCalendarDate+Windows.m
//  MulleObjCOSFoundation
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
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

// std-c and dependencies
#include <time.h>

// private stuff
#import <MulleObjCStandardFoundation/_MulleObjCConcreteCalendarDate.h>

#import "NSDate+Windows-Private.h"
#import "NSTimeZone+Windows-Private.h"
#include <MulleObjCStandardFoundation/mulle-mini-tm.h>
#include "Functions/mulle-windows-tm.h"


static time_t    mulle_mini_tm_get_time( struct mulle_mini_tm mini)
{
   struct tm   tmp;

   mulle_windows_tm_init_with_mini_tm( &tmp, mini);
   return( mulle_windows_tm_get_time( &tmp));
}


@implementation _MulleObjCConcreteCalendarDate( Windows)

static void  _MulleObjCConcreteCalendarDateInitWindows( _MulleObjCConcreteCalendarDate *self,
                                                        NSTimeInterval interval,
                                                        NSTimeZone *timeZone)
{
   struct tm   tmp;
   NSInteger   seconds;

   seconds = [timeZone mulleSecondsFromGMTForTimeIntervalSince1970:interval];
   mulle_windows_tm_init_with_interval1970( &tmp, interval, seconds);
   self->_tm.values = mulle_windows_tm_get_mini_tm( &tmp);
   self->_timeZone  = [timeZone retain];
}


+ (instancetype) newWithTimeIntervalSince1970:(NSTimeInterval) timeInterval
                                     timeZone:(NSTimeZone *) timeZone
{
   _MulleObjCConcreteCalendarDate  *obj;

   if( ! timeZone)
      timeZone = [NSTimeZone mulleGMTTimeZone];

   obj = NSAllocateObject( self, 0, NULL);
   _MulleObjCConcreteCalendarDateInitWindows( obj, timeInterval, timeZone);
   return( obj);
}


+ (instancetype) newWithTimeIntervalSince1970:(NSTimeInterval) timeInterval
{
   _MulleObjCConcreteCalendarDate   *obj;
   NSTimeZone                       *timeZone;

   timeZone = [NSTimeZone defaultTimeZone];
   obj      = NSAllocateObject( self, 0, NULL);
   _MulleObjCConcreteCalendarDateInitWindows( obj, timeInterval, timeZone);
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


- (NSTimeInterval) timeIntervalSinceReferenceDate
{
   time_t           value;
   NSTimeInterval   interval;

   value     = mulle_mini_tm_get_time( self->_tm.values);
   interval  = (NSTimeInterval) value;
   interval -= [_timeZone mulleSecondsFromGMTForTimeIntervalSince1970:interval];
   return( _NSTimeIntervalSince1970AsReferenceDate( interval));
}

@end


@implementation NSCalendarDate( Windows)

@dependency NSCalendarDate( NSUserDefaults);


- (instancetype) _initWithTM:(struct tm *) tm
                 nanoseconds:(unsigned long long) nanoseconds
                    timeZone:(NSTimeZone *) tz
{
   struct mulle_mini_tm   mini;

   MULLE_C_UNUSED( nanoseconds);
   mini = mulle_windows_tm_get_mini_tm( tm);
   return( [self mulleInitWithMiniTM:mini
                            timeZone:tz]);
}


- (instancetype) init
{
   NSTimeInterval   seconds;

   seconds = (NSTimeInterval) time( NULL);
   return( [_MulleObjCConcreteCalendarDate newWithTimeIntervalSince1970:seconds]);
}


- (instancetype) initWithTimeIntervalSince1970:(NSTimeInterval) timeInterval
{
   return( [_MulleObjCConcreteCalendarDate newWithTimeIntervalSince1970:timeInterval]);
}


- (instancetype) mulleInitWithTimeIntervalSince1970:(NSTimeInterval) timeInterval
                                           timeZone:(NSTimeZone *) tz
{
   return( [_MulleObjCConcreteCalendarDate newWithTimeIntervalSince1970:timeInterval
                                                               timeZone:tz]);
}


- (instancetype) initWithTimeIntervalSinceReferenceDate:(NSTimeInterval) timeInterval
{
   NSTimeInterval   since1970;

   since1970 = _NSTimeIntervalSinceReferenceDateAsSince1970( timeInterval);
   return( [_MulleObjCConcreteCalendarDate newWithTimeIntervalSince1970:since1970]);
}


- (instancetype) mulleInitWithTimeIntervalSinceReferenceDate:(NSTimeInterval) timeInterval
                                                    timeZone:(NSTimeZone *) tz
{
   NSTimeInterval   since1970;

   since1970 = _NSTimeIntervalSinceReferenceDateAsSince1970( timeInterval);
   return( [_MulleObjCConcreteCalendarDate newWithTimeIntervalSince1970:since1970
                                                               timeZone:tz]);
}


- (instancetype) mulleInitWithDate:(NSDate *) date
                          timeZone:(NSTimeZone *) tz
{
   NSTimeInterval   since1970;

   since1970 = [date timeIntervalSince1970];
   return( [_MulleObjCConcreteCalendarDate newWithTimeIntervalSince1970:since1970
                                                               timeZone:tz]);
}


- (instancetype) initWithDate:(NSDate *) date
{
   NSTimeInterval   since1970;

   since1970 = [date timeIntervalSince1970];
   return( [_MulleObjCConcreteCalendarDate newWithTimeIntervalSince1970:since1970]);
}


- (NSDate *) date
{
   return( [NSDate dateWithTimeIntervalSince1970:[self timeIntervalSince1970]]);
}


- (NSCalendarDate *) dateByAddingYears:(NSInteger) years
                                months:(NSInteger) months
                                  days:(NSInteger) days
                                 hours:(NSInteger) hours
                               minutes:(NSInteger) minutes
                               seconds:(NSInteger) seconds
{
   struct tm   tmp;

   mulle_windows_tm_init_with_mini_tm( &tmp, [self mulleMiniTM]);

   tmp.tm_year += years;
   tmp.tm_mon  += months;
   tmp.tm_mday += days;

   tmp.tm_hour += hours;
   tmp.tm_min  += minutes;
   tmp.tm_sec  += seconds;

   return( [[[[self class] alloc] _initWithTM:&tmp
                                  nanoseconds:0
                                     timeZone:[self timeZone]] autorelease]);
}

@end

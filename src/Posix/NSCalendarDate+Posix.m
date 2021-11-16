//
//  NSCalendarDate+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

// TODO: move stuff to Linux/Darwin because of timegm

#define _XOPEN_SOURCE 700  // linux: for various stuff
#define _DARWIN_C_SOURCE   // darwin: for timegm
#define _USE_MISC          // linux: for timegm
#define _GNUSOURCE         // linux: for timegm
#define _DEFAULT_SOURCE    // linux: for timegm  ARGH!!  why does this alway change ?
#import "import-private.h"

// std-c and dependencies
#include <time.h>


// private stuff
#import <MulleObjCStandardFoundation/_MulleObjCConcreteCalendarDate.h>

#import "NSDate+Posix-Private.h"
#import "NSTimeZone+Posix-Private.h"
#include <MulleObjCStandardFoundation/mulle-mini-tm.h>
#include "mulle-posix-tm.h"


static void   mulle_mini_tm_init_with_time( struct mulle_mini_tm *mini, time_t time)
{
   struct tm   tmp;

   if( ! mini)
      return;

   mulle_posix_tm_init_with_time( &tmp, time);
   *mini = mulle_posix_tm_get_mini_tm( &tmp);
}


static time_t    mulle_mini_tm_get_time( struct mulle_mini_tm mini)
{
   struct tm   tmp;

   mulle_posix_tm_init_with_mini_tm( &tmp, mini);
   return( timegm( &tmp));  // not super sure this doesn't get corrupted
}



@implementation _MulleObjCConcreteCalendarDate( Posix)

static void  _MulleObjCConcreteCalendarDateInitPosix( _MulleObjCConcreteCalendarDate *self,
                                                      NSTimeInterval interval,
                                                      NSTimeZone *timeZone)
{
   struct tm   tmp;
   NSInteger   seconds;

   seconds = [timeZone mulleSecondsFromGMTForTimeIntervalSince1970:interval];
   mulle_posix_tm_init_with_interval1970( &tmp, interval, seconds);
   self->_tm.values = mulle_posix_tm_get_mini_tm( &tmp);
   self->_timeZone  = [timeZone retain];
}


// use specified tz or "GMT" as default
+ (instancetype) newWithTimeIntervalSince1970:(NSTimeInterval) timeInterval
                                     timeZone:(NSTimeZone *) timeZone
{
   _MulleObjCConcreteCalendarDate  *obj;

   // nil timeZone = GMT
   if( ! timeZone)
      timeZone = [NSTimeZone mulleGMTTimeZone];  // GMT sic!

   obj = NSAllocateObject( self, 0, NULL);
   _MulleObjCConcreteCalendarDateInitPosix( obj, timeInterval, timeZone);
   return( obj);
}


+ (instancetype) newWithTimeIntervalSince1970:(NSTimeInterval) timeInterval
{
   _MulleObjCConcreteCalendarDate   *obj;
   NSTimeZone                       *timeZone;

   // use defaultTimeZone, that's what one would expect
   timeZone = [NSTimeZone defaultTimeZone];
   obj      = NSAllocateObject( self, 0, NULL);
   _MulleObjCConcreteCalendarDateInitPosix( obj, timeInterval, timeZone);
   return( obj);
}


- (NSTimeInterval) timeIntervalSince1970
{
   struct tm        tmp;
   time_t           value;
   NSTimeInterval   interval;

   value     = mulle_mini_tm_get_time( self->_tm.values);
   interval  = (NSTimeInterval) value;
   interval -= [_timeZone mulleSecondsFromGMTForTimeIntervalSince1970:interval];
   return( interval);
}


//
// Q: do we produce a value relative to GMT or to the current timeZone
//    to GMT ? NSDate is GMT always.
//
- (NSTimeInterval) timeIntervalSinceReferenceDate
{
   struct tm        tmp;
   time_t           value;
   NSTimeInterval   interval;

   value     = mulle_mini_tm_get_time( self->_tm.values);
   interval  = (NSTimeInterval) value;
   interval -= [_timeZone mulleSecondsFromGMTForTimeIntervalSince1970:interval];
   return( _NSTimeIntervalSince1970AsReferenceDate( interval));
}

@end


@implementation NSCalendarDate( Posix)

/*
 * Use _MulleObjCConcreteCalendarDate indirectly
 */
- (instancetype) _initWithTM:(struct tm *) tm
                 nanoseconds:(unsigned long long) nanoseconds  // ignored
                    timeZone:(NSTimeZone *) tz
{
   struct mulle_mini_tm   mini;

   mini = mulle_posix_tm_get_mini_tm( tm);
   return( [self mulleInitWithMiniTM:mini
                            timeZone:tz]);
}


/*
 * Use _MulleObjCConcreteCalendarDate directly
 */
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
   // convert to GMT
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

   mulle_posix_tm_init_with_mini_tm( &tmp, [self mulleMiniTM]);

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

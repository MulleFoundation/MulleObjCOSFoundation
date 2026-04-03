//
//  NSCalendarDate+Windows.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 05.02.26
//  Copyright © 2026 Mulle kybernetiK. All rights reserved.
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

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCDeps), @selector( MulleObjCOSWindowsFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}


- (instancetype) _initWithTM:(struct tm *) tm
                 nanoseconds:(unsigned long long) nanoseconds
                    timeZone:(NSTimeZone *) tz
{
   struct mulle_mini_tm   mini;

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

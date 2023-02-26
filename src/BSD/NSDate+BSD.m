//
//  NSCalendarDate+BSD.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 04.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#import "import-private.h"

// other files in this library
#import <MulleObjCPosixFoundation/NSDate+Posix-Private.h>
#import <MulleObjCStandardFoundation/_MulleObjCConcreteCalendarDate.h>
#include "mulle-bsd-tm.h"

// std-c and dependencies
#include <time.h>



static void   mulle_mini_tm_init_with_time( struct mulle_mini_tm *mini, time_t time)
{
   struct tm   tmp;

   if( ! mini)
      return;

   mulle_bsd_tm_init_with_time( &tmp, time);
   *mini = mulle_posix_tm_get_mini_tm( &tmp);
}


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

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCPosixFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}


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
   struct tm        tmp;
   time_t           value;
   NSTimeInterval   interval;

   value     = mulle_mini_tm_get_time( self->_tm.values);
   interval  = (NSTimeInterval) value;
   interval -= [_timeZone mulleSecondsFromGMTForTimeIntervalSince1970:interval];
   return( interval);
}

@end




@implementation NSCalendarDate( BSD)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCPosixFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}


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



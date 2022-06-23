//
//  NSDate+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
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

//
//  NSDate+Posix.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#ifndef mulle_posix_tm_h__
#define mulle_posix_tm_h__

#include <time.h>


// time the old enemy, what it is it ?
//
// https://en.wikipedia.org/wiki/Planck_time
// Assume the universe is a computer that has a tick rate called "planck time"
// A second is currently ~ 5*10^44 ticks.
//
// The second is defined as 9,192,631,770 periods of a certain frequency of
// radiation from the caesium atom: a so-called atomic clock. Lets's assume for
// our purposes that this is a coarse way to get at the ticks.
//
// This physical time is also known as "dynamical time" [Cal. Cals, Dershowitz,Rheingold]
//
// But a second is also one minute / 60. Where a minute is 1 hour / 60. Where
// 1 hour is 1 day / 24. And a day is midnight to midnight. And that duration
// does change because the earth wobbles and slows down, whereas the tickrate
// doesn't.
//
// This time is also known as "solar time" [Cal. Cals, Dershowitz,Rheingold]
//
// https://en.wikipedia.org/wiki/Coordinated_Universal_Time
//
// Our clock time is based on UTC. To match up UTC with
// the ticks, occasionally there are leap seconds introduced. But UTC never
// really matches, it just approximates. The duration of a second is kept
// constant though.
//
// It could be easier, but then it's not.
//
// Assume someone counted all the seconds starting from 1.1.1970 midnight. That
// is the reference tick. It's physical time. To match things with the solar time
// the "International Telecommunications Union" may add or subtracts leap seconds
// at the end of each month(!). In reality there have been as of July 2015,
// 26 leap seconds in total, all positive.
//
// NSDate contains a NSTimeInterval. It's not per se UTC!

// TODO: I am tempted to make locale_t a  mulle_locale_t which is an void *

int   mulle_posix_tm_from_string_with_format( struct tm *tm,
                                              char **c_str_p,
                                              char *c_format,
                                              locale_t locale,
                                              int is_lenient);

void           mulle_posix_tm_invalidate( struct tm *tm);
int            mulle_posix_tm_is_invalid( struct tm *tm);
unsigned int   mulle_posix_tm_augment( struct tm *tm, struct tm *now);

static inline
struct mulle_mini_tm   mulle_posix_tm_get_mini_tm( struct tm *src)
{
   struct mulle_mini_tm   dst;

   if( ! src)
   {
      memset( &dst, 0, sizeof( dst));
      return( dst);
   }

   dst.year   = src->tm_year + 1900;
   dst.month  = src->tm_mon;
   dst.day    = src->tm_mday;
   dst.hour   = src->tm_hour;
   dst.minute = src->tm_min;
   dst.second = src->tm_sec;

   return( dst);
}


static inline void  mulle_posix_tm_init_with_mini_tm( struct tm *dst,
                                                      struct mulle_mini_tm src)
{
   if( ! dst)
      return;

   memset( dst, 0, sizeof( *dst)); // most compatible, though wasteful

   dst->tm_year   = src.year - 1900;
   dst->tm_mon    = src.month;
   dst->tm_mday   = src.day;
   dst->tm_hour   = src.hour;
   dst->tm_min    = src.minute;
   dst->tm_sec    = src.second;
}


void    mulle_posix_tm_init_with_time( struct tm *tm, time_t time);
time_t  mulle_posix_tm_get_time( struct tm *tm);


// the offset is for compatibility with BSD
void  mulle_posix_tm_init_with_interval1970( struct tm *tm,
                                             double timeInterval,
                                             int offset);

#endif

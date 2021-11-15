//
//  NSDate+Posix.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#define _XOPEN_SOURCE 700
#define _DARWIN_C_SOURCE   // darwin: for timegm
#define _DEFAULT_SOURCE

#include "include-private.h"

// std-c and dependencies
#include <limits.h>
#include <time.h>
#include <locale.h>
#include <string.h>

// private stuff
#include <MulleObjCStandardFoundation/mulle-mini-tm.h>
#include "mulle-posix-tm.h"


void  mulle_posix_tm_invalidate( struct tm *tm)
{
   tm->tm_sec    = INT_MIN;
   tm->tm_min    = INT_MIN;
   tm->tm_hour   = INT_MIN;
   tm->tm_mday   = INT_MIN;
   tm->tm_mon    = INT_MIN;
   tm->tm_year   = INT_MIN;
   tm->tm_wday   = INT_MIN;
   tm->tm_yday   = INT_MIN;
   tm->tm_isdst  = INT_MIN;
}


int    mulle_posix_tm_is_invalid( struct tm *tm)
{
   if( tm->tm_sec == INT_MIN)
      return( 1);
   if( tm->tm_min == INT_MIN)
      return( 1);
   if( tm->tm_hour == INT_MIN)
      return( 1);
   if( tm->tm_mday == INT_MIN && tm->tm_wday == INT_MIN && tm->tm_yday == INT_MIN)
      return( 1);
   if( tm->tm_year == INT_MIN)
      return( 1);
   return( 0);
}


unsigned int   mulle_posix_tm_augment( struct tm *tm, struct tm *now)
{
   unsigned int  n;

   n = 0;

   if( tm->tm_sec == INT_MIN)
   {
      ++n;
      tm->tm_sec = now->tm_sec;
   }
   if( tm->tm_min == INT_MIN)
   {
      ++n;
      tm->tm_min = now->tm_min;
   }
   if( tm->tm_hour == INT_MIN)
   {
      ++n;
      tm->tm_hour = now->tm_hour;
   }
   if( tm->tm_mday == INT_MIN && tm->tm_wday == INT_MIN && tm->tm_yday == INT_MIN)
   {
      ++n;
      tm->tm_mday = now->tm_mday;
   }

   if( tm->tm_mon == INT_MIN)
   {
      ++n;
      tm->tm_mon = now->tm_mon;
   }

   if( tm->tm_year == INT_MIN)
   {
      ++n;
      tm->tm_year = now->tm_year;
   }

   return( n);
}


int   mulle_posix_tm_from_string_with_format( struct tm *tm,
                                              char **c_str_p,
                                              char *c_format,
                                              locale_t locale,
                                              int is_lenient)
{
   char           *c_str;
   locale_t       old_xlocale;
   struct tm      now;
   time_t         nowtimeval;
   unsigned int   n;

   // set it all to int min, that way we can deduce how much
   // strptime was able to parse for "leniency"

   mulle_posix_tm_invalidate( tm);

   old_xlocale = (locale_t) -1;
   if( locale)
      old_xlocale = uselocale( locale);

   // TODO: we don't parse %F correctly, but strptime doesn't know it.
   //       and tm doesn't know it either.
   c_str     = *c_str_p;
   *c_str_p  = strptime( c_str, c_format, tm);

   if( old_xlocale != (locale_t) -1)
      uselocale( old_xlocale);

   if( ! *c_str_p)
   {
      if( ! is_lenient)
         return( -1);
   }

   if( mulle_posix_tm_is_invalid( tm))
   {
      // augment formatter with current time (or only when parsing failed ?)
      nowtimeval = time( NULL);
      gmtime_r( &nowtimeval, &now);  // localtime, gmtime ???

      n = mulle_posix_tm_augment( tm, &now);

      // absolutely no conversion and we failed parsing, strange
      if( ! n && ! *c_str_p)
         return( -1);
   }

   return( 0);
}



void   mulle_posix_tm_init_with_time( struct tm *tm, time_t time)
{
   if( ! tm)
      return;

   gmtime_r( &time, tm);
}


time_t  mulle_posix_tm_get_time( struct tm *tm)
{
   struct tm   tmp;

   if( ! tm)
      return( 0);

   tmp = *tm;              // not super sure this doesn't get corrupted
   return( timegm( &tmp));
}



void   mulle_posix_tm_init_with_interval1970( struct tm *tm,
                                              double timeInterval,
                                              int offset)
{
   time_t      timeval;

   // MEMO: rounding is bad here. Why ? When we format something
   // with %F (ms) we format it outside of strftime. struct tm does not
   // know about ms. So if we round, 0.75 will be printed as 1.72 if
   // we round timeInterval, so we floor it intentionally
   timeval = (time_t) timeInterval + offset;
   gmtime_r( &timeval, tm);
}


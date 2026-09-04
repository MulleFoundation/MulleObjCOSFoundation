//
//  mulle-windows-tm.c
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
#include "include-private.h"

// std-c and dependencies
#include <limits.h>
#include <time.h>
#include <string.h>
#include <windows.h>

// private stuff
#include <MulleObjCStandardFoundation/mulle-mini-tm.h>
#include "mulle-windows-tm.h"


#define SECS_PER_400_YEARS  12622780800LL


void  mulle_windows_tm_invalidate( struct tm *tm)
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


int    mulle_windows_tm_is_invalid( struct tm *tm)
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


void   mulle_windows_tm_init_with_time( struct tm *tm, time_t time)
{
   struct tm   *result;
   int          shifts;

   if( ! tm)
      return;

   shifts = 0;
   while( time < 0)
   {
      time += (time_t) SECS_PER_400_YEARS;
      shifts++;
   }

   result = gmtime( &time);
   if( result)
   {
      *tm = *result;
      tm->tm_year -= shifts * 400;
   }
}


time_t  mulle_windows_tm_get_time( struct tm *tm)
{
   struct tm   tmp;
   int         shifts;
   time_t      result;

   if( ! tm)
      return( 0);

   tmp    = *tm;
   shifts = 0;
   while( tmp.tm_year + 1900 < 1970)
   {
      tmp.tm_year += 400;
      shifts++;
   }

   result = _mkgmtime( &tmp);

   if( shifts)
      result -= (time_t) shifts * SECS_PER_400_YEARS;

   return( result);
}


void   mulle_windows_tm_init_with_interval1970( struct tm *tm,
                                                double timeInterval,
                                                int offset)
{
   time_t      timeval;
   struct tm   *result;
   int          shifts;

   timeval = (time_t) timeInterval + offset;
   shifts  = 0;
   while( timeval < 0)
   {
      timeval += (time_t) SECS_PER_400_YEARS;
      shifts++;
   }

   result = gmtime( &timeval);
   if( result)
   {
      *tm = *result;
      tm->tm_year -= shifts * 400;
   }
}


struct mulle_mini_tm   mulle_windows_tm_get_mini_tm( struct tm *src)
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


void   mulle_windows_tm_init_with_mini_tm( struct tm *dst,
                                           struct mulle_mini_tm src)
{
   if( ! dst)
      return;

   memset( dst, 0, sizeof( *dst));

   dst->tm_year   = src.year - 1900;
   dst->tm_mon    = src.month;
   dst->tm_mday   = src.day;
   dst->tm_hour   = src.hour;
   dst->tm_min    = src.minute;
   dst->tm_sec    = src.second;
   dst->tm_isdst  = -1;
}

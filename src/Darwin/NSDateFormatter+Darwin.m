//
//  NSDateFormatter+Darwin.m
//  MulleObjCOSFoundation
//
//  Copyright (c) 2018 Nat! - Mulle kybernetiK.
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

// other libraries of MulleObjCPosixFoundation
#import <MulleObjCOSBaseFoundation/NSDate+OSBase-Private.h>
#import <MulleObjCPosixFoundation/NSLocale+Posix-Private.h>
#include <MulleObjCStandardFoundation/mulle-mini-tm.h>
#import <MulleObjCPosixFoundation/mulle-posix-tm.h>

// std-c and dependencies
#import <time.h>
#import <xlocale.h>


#pragma clang diagnostic ignored "-Wparentheses"

@implementation NSDateFormatter( Darwin)

@dependency NSDateFormatter( BSD);

//
// as strange as it may sound, on DARWIN strftime is broken (by design)
// with respect to %z and %Z
// https://opensource.apple.com/source/Libc/Libc-1244.30.3/stdtime/FreeBSD/strftime.c.auto.html
//
// So we preparse the format and output the correct timezone into a copy
// of the format string :(
// W
//
static char  *percent_z_find( char *s)
{
   int   c;
   int   d;

   // search for %z or %Z
   c = 0;
   for(;;)
   {
      d = c;
      c = *s++;
      if( ! c)
         break;

      if( d != '%')
         continue;

      if( c == 'z' || c == 'Z')
         return( s - 2);

      c = 0;  // look for % again
   }
   return( NULL);
}


// static unsigned int   percent_count( char *s)
// {
//    int           c;
//    unsigned int  n;
//
//    n = 0;
//    while( c = *s++)
//       if( c == '%')
//          ++n;
//
//    return( n);
// }
//
//
// static void   percent_escape( char *dst, char *src)
// {
//    int   c;
//
//    do
//    {
//       c = *src++;
//       if( c == '%')
//          *dst++ = c;
//       *dst++ = c;
//    }
//    while( c);
// }


static void   percent_z_replace( char *dst,
                                 char *src,
                                 struct tm *tm,
                                 size_t tzname_len)
{
   int   c;
   int   d;
   int   secs;
   int   mins;
   int   sign;

   // search for %z or %Z, and replace with tm info
   c = 0;
   for(;;)
   {
      d = c;
      c = *src++;
      if( ! c)
      {
         *dst++ = c;
         return;
      }

      if( d != '%')
      {
         if( c != '%')
            *dst++ = c;
         continue;
      }

      switch( c)
      {
      case 'z' :
         secs = tm->tm_gmtoff;
         sign = '+';
         if( secs < 0)
         {
            sign = '-';
            secs = -secs;
         }

         // copied from bsd, i have no idea what this does
         mins = secs / 60;
         mins = (mins / 60) * 100 + (mins % 60);

         // own code
         *dst++ = sign;
         mins %= 10000;
         *dst++ = '0' + (mins / 1000);
         mins %= 1000;
         *dst++ = '0' + (mins / 100);
         mins %= 100;
         *dst++ = '0' + (mins / 10);
         mins %= 10;
         *dst++ = '0' + mins;
         break;

      case 'Z' :
         memcpy( dst, tm->tm_zone, tzname_len);
         dst += tzname_len;
         break;

      default :
         *dst++ = '%';
         *dst++ = c;
      }
      c = 0;
   }
}



- (size_t) _printTM:(struct tm *) tm
             buffer:(char *) buf
             length:(size_t) len
      formatUTF8String:(char *) c_format
             locale:(NSLocale *) locale
{
   locale_t    xlocale;
   char        *start;
   size_t      tzname_len;
   size_t      needed_len;

   NSParameterAssert( tm);
   NSParameterAssert( c_format);
   NSParameterAssert( [locale isKindOfClass:[NSLocale class]]);

   xlocale = [locale xlocale];

   start = percent_z_find( c_format);
   if( ! start)
   {
      if( xlocale)
         len = strftime_l( buf, len, c_format, tm, xlocale);
      else
         len = strftime( buf, len, c_format, tm);
      return( len);
   }

   //
   // calculate what we need to convert
   //
   tzname_len = 0;
   needed_len = strlen( c_format);

   do
   {
      if( start[ 1] == 'Z')
      {
         if( ! tzname_len)
         {
            if( ! tm->tm_zone)
               MulleObjCThrowInvalidArgumentException( @"Timezone name is needed");
            if( strchr( tm->tm_zone, '%'))
               MulleObjCThrowInvalidArgumentException( @"Timezone with %% is not possible");
            tzname_len = strlen( tm->tm_zone);
         }
         needed_len += tzname_len - 2;  // - %Z
      }
      else
         needed_len += 5 - 2; // (sign + 0000) - (%z)

      start = percent_z_find( start + 2);
   }
   while( start);

   if( needed_len > 1024)
      MulleObjCThrowInvalidArgumentException( @"Format string too long");

   //
   // now convert the c_format into a temporary buffer
   // with expanded %z and %Z values. needed_len fits tight.
   //
   {
      char  tmp_format[ needed_len + 1 + 1];

#ifndef NDEBUG
      tmp_format[ needed_len]     = -38;
      tmp_format[ needed_len + 1] = -38;
#endif
      percent_z_replace( tmp_format, c_format, tm, tzname_len);

      assert( tmp_format[ needed_len] == 0);
      assert( tmp_format[ needed_len + 1] == -38);

      if( xlocale)
         len = strftime_l( buf, len, tmp_format, tm, xlocale);
      else
         len = strftime( buf, len, tmp_format, tm);
      return( len);
   }
}

@end

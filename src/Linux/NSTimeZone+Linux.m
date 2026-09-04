//
//  NSTimeZone+Linux.m
//  MulleObjCOSFoundation
//
//  Copyright (c) 2017 Nat! - Mulle kybernetiK.
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
#define _GNU_SOURCE

#import "import-private.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation
#import <MulleObjCPosixFoundation/NSTimeZone+Posix-Private.h>


@implementation NSTimeZone( Linux)

@dependency NSTimeZone( Posix);

- (NSTimeInterval) _timeIntervalSince1970ForTM:(struct tm *) tm
{
   extern long        mulle_get_timeinterval_for_tm( void *, struct tz_tm *);
   struct tz_tm       tmp;
   NSTimeInterval     interval;

   tmp.tm_sec  = tm->tm_sec;
   tmp.tm_min  = tm->tm_min;
   tmp.tm_hour = tm->tm_hour;
   tmp.tm_mday = tm->tm_mday;
   tmp.tm_mon  = tm->tm_mon;
   tmp.tm_year = tm->tm_year;

   tmp.tm_isdst = tm->tm_isdst;
   tmp.tm_wday  = 0;
   tmp.tm_yday  = 0;

   interval = (NSTimeInterval) mulle_get_timeinterval_for_tm( [_data bytes], &tmp);
   if( interval == -1)
      MulleObjCThrowInvalidArgumentException( @"time can not be converted");

   tm->tm_sec  = tmp.tm_sec;
   tm->tm_min  = tmp.tm_min;
   tm->tm_hour = tmp.tm_hour;
   tm->tm_mday = tmp.tm_mday;
   tm->tm_mon  = tmp.tm_mon;
   tm->tm_year = tmp.tm_year;

   tm->tm_isdst = tmp.tm_isdst;
   tm->tm_wday  = tmp.tm_wday;
   tm->tm_yday  = tmp.tm_yday;

   return( interval);
}

@end

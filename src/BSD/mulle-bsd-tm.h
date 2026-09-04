//
//  mulle-bsd-tm.h
//  MulleObjCOSFoundation
//
//  Copyright (c) 2021 Nat! - Mulle kybernetiK.
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
#ifndef mulle_bsd_tm_h__
#define mulle_bsd_tm_h__

#include <time.h>
#include <xlocale.h>

#include <MulleObjCStandardFoundation/mulle-mini-tm.h>
#include <MulleObjCPosixFoundation/mulle-posix-tm.h>


enum mulle_bsd_tm_status
{
   mulle_bsd_tm_error   = -1,
   mulle_bsd_tm_no_tz   = 0,
   mulle_bsd_tm_with_tz = 1
};



void           mulle_bsd_tm_invalidate( struct tm *tm);
int            mulle_bsd_tm_is_invalid( struct tm *tm);
unsigned int   mulle_bsd_tm_augment( struct tm *tm,
                                     struct tm *now,
                                     enum mulle_bsd_tm_status *has_tz);


enum mulle_bsd_tm_status   
   mulle_bsd_tm_from_string_with_format( struct tm *tm,
                                         char **c_str_p,
                                         char *c_format,
                                         locale_t locale,
                                         int is_lenient);

void   mulle_bsd_tm_init_with_interval1970( struct tm *tm,
                                            double timeInterval,
                                            int secondsFromGMT);



static inline struct mulle_mini_tm
   mulle_bsd_tm_get_mini_tm( struct tm *src)
{
   return( mulle_posix_tm_get_mini_tm( src));
}


static inline void  mulle_bsd_tm_init_with_mini_tm( struct tm *dst,
                                                    struct mulle_mini_tm src)
{
    mulle_posix_tm_init_with_mini_tm( dst, src);
}


static inline void    mulle_bsd_tm_init_with_time( struct tm *tm, time_t time)
{
   mulle_posix_tm_init_with_time( tm, time);
}


static inline time_t   mulle_bsd_tm_get_time( struct tm *tm)
{
   return( mulle_posix_tm_get_time( tm));
}

#endif

//
//  mulle_bsd_tm.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
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

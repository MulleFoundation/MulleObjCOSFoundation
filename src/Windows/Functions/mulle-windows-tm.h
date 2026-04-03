//
//  mulle-windows-tm.h
//  MulleObjCWindowsFoundation
//
//  Created by Nat! on 05.02.26
//  Copyright © 2026 Mulle kybernetiK. All rights reserved.
//
#ifndef mulle_windows_tm_h__
#define mulle_windows_tm_h__

#include <time.h>


void           mulle_windows_tm_invalidate( struct tm *tm);
int            mulle_windows_tm_is_invalid( struct tm *tm);

struct mulle_mini_tm   mulle_windows_tm_get_mini_tm( struct tm *src);
void                   mulle_windows_tm_init_with_mini_tm( struct tm *dst, struct mulle_mini_tm src);

void    mulle_windows_tm_init_with_time( struct tm *tm, time_t time);
time_t  mulle_windows_tm_get_time( struct tm *tm);

void  mulle_windows_tm_init_with_interval1970( struct tm *tm,
                                               double timeInterval,
                                               int offset);

#endif

//
//  NSCalendarDate+BSD.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 04.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#import "import-private.h"

// other files in this library
#import <MulleObjCPosixFoundation/private/NSCalendarDate+Posix-Private.h>

// std-c and dependencies
#include <time.h>


@interface NSTimeZone( Posix)

- (NSInteger) mulleSecondsFromGMTForTimeIntervalSince1970:(NSTimeInterval) interval;

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
                    timeZone:(NSTimeZone *) tz
{
   time_t           timeval;
   NSTimeInterval   interval;

   timeval  = timegm( tm);
   interval = timeval - [tz secondsFromGMT];

   return( [self initWithTimeIntervalSince1970:interval
                                      timeZone:tz]);
}


- (NSTimeInterval) timeIntervalSince1970
{
   struct tm   tmp;
   time_t      value;

   mulle_tm_with_mini_tm( &tmp, self->_tm.values);
   value  = timegm( &tmp);
   value -= [_timeZone mulleSecondsFromGMTForTimeIntervalSince1970:value];
   return( (NSTimeInterval) value);
}

@end

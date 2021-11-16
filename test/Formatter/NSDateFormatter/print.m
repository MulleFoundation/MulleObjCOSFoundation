//
//  main.m
//  archiver-test
//
//  Created by Nat! on 19.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#ifdef __MULLE_OBJC__
# import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif



int   main( int argc, const char * argv[])
{
   NSDateFormatter   *formatter;
   NSCalendarDate    *date;
   NSTimeZone        *timeZone;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   formatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%dT%H:%M:%SZ%z"
                                       allowNaturalLanguage:NO] autorelease];

   timeZone = [NSTimeZone timeZoneForSecondsFromGMT:3*60*60];
#ifdef __MULLE_OBJC__
   date     = [[[NSCalendarDate alloc] mulleInitWithTimeIntervalSinceReferenceDate:(24*60*60)*33+(01*60*60)+(5*60)+6
                                                                          timeZone:timeZone] autorelease];
#else
   date     = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:(24*60*60)*33+(01*60*60)+(5*60)+6] autorelease];
   [date setTimeZone:timeZone];
#endif
   printf( "%s (%.f)\n", [[formatter stringFromDate:date] UTF8String], [date timeIntervalSinceReferenceDate]);

   return( 0);
}

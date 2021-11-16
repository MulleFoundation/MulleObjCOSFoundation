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
# pragma message( "Apple Foundation")
#endif


static void   printDate( id date)
{
   NSDateFormatter   *formatter;
   NSString          *s;

   formatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%y-%m-%dT%H:%M:%S%z"
                                       allowNaturalLanguage:NO] autorelease];

   printf( "%s %.3f -> ",
      [NSStringFromClass( [date class]) UTF8String],
      [date timeIntervalSinceReferenceDate]);

   s = [formatter stringFromDate:date];
   if( ! s)
      printf( "*nil*");
   else
      printf( "\"%s\"", [s UTF8String]);
   printf( "\n");
}


int   main( int argc, const char * argv[])
{
   NSDate            *date;
   NSCalendarDate    *today;
   NSDateFormatter   *formatter;
   NSString          *s;
   char              **p;
   NSTimeZone        *timeZone;
   NSTimeInterval    interval;
   NSTimeInterval    interval1970;
#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif
   timeZone = [NSTimeZone timeZoneForSecondsFromGMT:60*60*6];
   [NSTimeZone setDefaultTimeZone:timeZone];

   interval     = 12 * 60 * 60;
   interval1970 = interval + NSTimeIntervalSince1970;

   printf( "NSDate\n");
   date = [[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:interval] autorelease];
   printDate( date);

   date = [[[NSDate alloc] initWithTimeIntervalSince1970:interval1970] autorelease];
   printDate( date);


   printf( "NSCalendarDate (ReferenceDate)\n");
   // noon 2000
   today = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:interval] autorelease];
   printDate( today);

#ifdef __MULLE_OBJC__
   today = [[[NSCalendarDate alloc] mulleInitWithTimeIntervalSinceReferenceDate:interval
                                                                       timeZone:timeZone] autorelease];
   printDate( today);
#endif

   printf( "NSCalendarDate (Since1970)\n");
   today = [[[NSCalendarDate alloc] initWithTimeIntervalSince1970:interval1970] autorelease];
   printDate( today);


#ifdef __MULLE_OBJC__
   today = [[[NSCalendarDate alloc] mulleInitWithTimeIntervalSince1970:interval1970
                                                              timeZone:timeZone] autorelease];
   printDate( today);
#endif

   printf( "NSCalendarDate (Date)\n");
   today = [[[NSCalendarDate alloc] initWithDate:date] autorelease];
   printDate( today);

#ifdef __MULLE_OBJC__
   today = [[[NSCalendarDate alloc] mulleInitWithDate:date
                                             timeZone:timeZone] autorelease];
   printDate( today);
#endif
   return( 0);
}

/*

OS X is kinda broken IMO so let's not use it as reference

today -> 516492000.000 -> "17-05-15T00:00:00Z+0200"
Yesterday -> 516448800.000 -> "17-05-14T12:00:00Z+0200"
TOMORROW -> 516621600.000 -> "17-05-16T12:00:00Z+0200"
next friday -> 516880800.000 -> "17-05-19T12:00:00Z+0200" ???
last may -> 516535200.000 -> "17-05-15T12:00:00Z+0200"    ???
next april -> 513943200.000 -> "17-04-15T12:00:00Z+0200"  ???

*/

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

   formatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%y-%m-%dT%H:%M:%SZ%z"
                                       allowNaturalLanguage:NO] autorelease];

   mulle_printf( "%s %.3f -> ",
      [NSStringFromClass( [date class]) UTF8String],
      [date timeIntervalSinceReferenceDate]);

   s = [formatter stringFromDate:date];
   if( ! s)
      mulle_printf( "*nil*");
   else
      mulle_printf( "\"%s\"", [s UTF8String]);
   mulle_printf( "\n");
}


int   main( int argc, const char * argv[])
{
   NSDate            *date;
   NSCalendarDate    *today;
   NSDateFormatter   *formatter;
   NSString          *s;
   char              **p;
   NSTimeZone        *whatever;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   [NSTimeZone setDefaultTimeZone:[NSTimeZone mulleGMTTimeZone]];

   whatever = [NSTimeZone timeZoneForSecondsFromGMT:-2 * 60 * 60];
   today    = [[[NSCalendarDate alloc] mulleInitWithTimeIntervalSinceReferenceDate:12 * 60 * 60
                                                                          timeZone:whatever] autorelease];

   printDate( today);

   date = [[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:12 * 60 * 60] autorelease];
   printDate( date);

   mulle_printf( "NSCalendarDate %s NSDate\n", [date isEqual:today] ? "equals" : "not equals");
   mulle_printf( "NSDate %s NSCalendarDate\n", [today isEqual:date] ? "equals" : "not equals");

   return( 0);
}


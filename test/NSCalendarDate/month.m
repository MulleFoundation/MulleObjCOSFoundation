//
//  month.m
//  MulleObjCOSFoundation
//
//  Regression test: NSCalendarDate -monthOfYear must be 1-based (9 for
//  September), both when the date is built from a time interval and when it
//  is built from year/month/day components.
//
#ifdef __MULLE_OBJC__
# import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
#else
# import <Foundation/Foundation.h>
# pragma message( "Apple Foundation")
#endif


int   main( int argc, const char * argv[])
{
   NSCalendarDate   *date;
   NSTimeZone       *gmt;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   gmt = [NSTimeZone mulleGMTTimeZone];

   // 2026-09-29 00:00:00 UTC as a reference date (since 2001-01-01)
   date = [[[NSCalendarDate alloc] mulleInitWithTimeIntervalSinceReferenceDate:812332800.0
                                                                      timeZone:gmt] autorelease];
   mulle_printf( "from interval: %04ld-%02ld-%02ld %02ld:%02ld:%02ld\n",
                 (long) [date yearOfCommonEra],
                 (long) [date monthOfYear],
                 (long) [date dayOfMonth],
                 (long) [date hourOfDay],
                 (long) [date minuteOfHour],
                 (long) [date secondOfMinute]);

   // September 29 2026 00:00 GMT
   date = [NSCalendarDate dateWithYear:2026
                                 month:9
                                   day:29
                                  hour:0
                                minute:0
                                second:0
                              timeZone:gmt];
   mulle_printf( "from components: month %ld, since1970 %.0f\n",
                 (long) [date monthOfYear],
                 [date timeIntervalSince1970]);

   return( 0);
}

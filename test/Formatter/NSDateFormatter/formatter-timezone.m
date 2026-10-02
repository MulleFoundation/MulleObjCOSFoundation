//
//  formatter-timezone.m
//  MulleObjCOSFoundation
//
//  Regression test: -dateFromString: must interpret the parsed fields in the
//  formatter's timeZone, the same zone -stringFromDate: prints with. The
//  format's literal "Z" is just a character, not a zone specification.
//
#ifdef __MULLE_OBJC__
# import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
#else
# import <Foundation/Foundation.h>
# pragma message( "Apple Foundation")
#endif


int   main( int argc, const char * argv[])
{
   NSDateFormatter   *formatter;
   NSDate            *date;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   formatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%dT%H:%M:%SZ"
                                       allowNaturalLanguage:NO] autorelease];
   // a fixed +01:00 zone makes the test independent of the host timezone
   [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:60 * 60]];

   date = [formatter dateFromString:@"2013-02-24T20:09:15Z"];

   // round-trips the wall clock, and 20:09:15 +01:00 is 19:09:15 UTC
   mulle_printf( "%s\n", [[formatter stringFromDate:date] UTF8String]);
   mulle_printf( "%.0f\n", [date timeIntervalSince1970]);

   return( 0);
}

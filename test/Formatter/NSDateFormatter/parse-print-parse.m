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


static void   test_formatter( NSDateFormatter *formatter,
                              NSString *dateString,
                              int depth)
{
   NSDate     *date;
   NSString   *s;

   date = [formatter dateFromString:dateString];
   s    = [formatter stringFromDate:date];

   printf( "   %s: %s (%0.17g)\n",
               [NSStringFromClass( [date class]) UTF8String],
               [s UTF8String],
               [date timeIntervalSinceReferenceDate]);

   if( ! depth)
      test_formatter( formatter, s, 1);
}


static void   test( NSDateFormatter *formatter, NSString *dateString)
{
   printf( "%s\n", [dateString UTF8String]);

   [formatter setGeneratesCalendarDates:NO];
   test_formatter( formatter, dateString, 0);

   [formatter setGeneratesCalendarDates:YES];
   test_formatter( formatter, dateString, 0);
}


int   main( int argc, const char * argv[])
{
   NSDateFormatter   *formatter;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   formatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%dT%H:%M:%S:%F%z"
                                       allowNaturalLanguage:NO] autorelease];

   test( formatter, @"1970-01-01T00:00:00:000+0000");
   test( formatter, @"1970-01-01T00:00:00:000+0300");

   test( formatter, @"2013-12-11T10:09:08:765+0000");
   test( formatter, @"2013-12-11T10:09:08:765+01:00");
   // some wacky timezone
   test( formatter, @"2013-02-24T20:08:15:123+0845");

   return( 0);
}

//
//  delimiters.m
//  MulleObjCOSFoundation
//
//  Regression test: the four quotation delimiter keys and -calendarIdentifier
//  used to always answer nil. They follow from the identifier alone, so the
//  platform agnostic part of NSLocale answers them from small hand-rolled
//  tables of the CLDR values (no ICU dependency).
//
//  Only the *code points* are printed, so the expected output does not depend
//  on the encoding of the terminal, of the golden file or of the platform:
//    U+201C U+201D U+2018 U+2019  the English/neutral quotes
//    U+201E U+201C U+201A U+2018  the germanic ones
//    U+00AB U+00BB U+2039 U+203A  the french/guillemet family
//    U+300C U+300D U+300E U+300F  the japanese corner brackets
//
//  The last two lines pin down the two keys that this library deliberately
//  does *not* answer (see NSLocale.h): an NSCalendar object and CLDR exemplar
//  data are out of reach here.
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

#include <stdio.h>


static void   dump( char *tag, id s)
{
   if( ! s)
   {
      mulle_printf( "%s=(nil)\n", tag);
      return;
   }
   mulle_printf( "%s=U+%04lX\n", tag, (unsigned long) [s characterAtIndex:0]);
}


static void   dumpLocale( char *tag, NSString *identifier)
{
   NSLocale   *locale;
   char       buffer[ 64];

   locale = [NSLocale localeWithLocaleIdentifier:identifier];

   snprintf( buffer, sizeof( buffer), "%s.begin", tag);
   dump( buffer, [locale objectForKey:NSLocaleQuotationBeginDelimiterKey]);

   snprintf( buffer, sizeof( buffer), "%s.end", tag);
   dump( buffer, [locale objectForKey:NSLocaleQuotationEndDelimiterKey]);

   snprintf( buffer, sizeof( buffer), "%s.altbegin", tag);
   dump( buffer, [locale objectForKey:NSLocaleAlternateQuotationBeginDelimiterKey]);

   snprintf( buffer, sizeof( buffer), "%s.altend", tag);
   dump( buffer, [locale objectForKey:NSLocaleAlternateQuotationEndDelimiterKey]);

   snprintf( buffer, sizeof( buffer), "%s.calendar", tag);
   mulle_printf( "%s=%s\n", buffer, [[locale calendarIdentifier] UTF8String]);
}


int   main( int argc, const char * argv[])
{
   NSLocale   *locale;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      dumpLocale( "en-us", @"en_US");
      dumpLocale( "de-de", @"de_DE");
      dumpLocale( "fr-fr", @"fr_FR");
      dumpLocale( "ja-jp", @"ja_JP");
      dumpLocale( "ru-ru", @"ru_RU");

      // a language alone is enough for the calendar of these two
      dumpLocale( "th-th", @"th_TH");
      dumpLocale( "fa-ir", @"fa_IR");

      // the islamic calendar is *not* the default for ar_SA, neither in CLDR
      // nor on Apple, so this is gregorian
      dumpLocale( "ar-sa", @"ar_SA");

      // a language the table does not know gets the English quotes
      dumpLocale( "unknown", @"xx_YY");

      locale = [NSLocale localeWithLocaleIdentifier:@"de_DE"];
      mulle_printf( "calendar-key=%s\n", [locale objectForKey:NSLocaleCalendar] ? "SOME" : "nil");
      mulle_printf( "exemplar-key=%s\n",
                    [locale objectForKey:NSLocaleExemplarCharacterSet] ? "SOME" : "nil");
   }

   return( 0);
}

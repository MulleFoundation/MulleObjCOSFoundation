//
//  derived-keys.m
//  MulleObjCOSFoundation
//
//  Regression test: these NSLocale keys had no POSIX source at all and always
//  came back nil. They are all derivable from the locale identifier, which is
//  shaped "language[_country][.codeset][@modifier]" - optionally with a script
//  ("zh_Hans_CN"), and with "-" tolerated as a component separator (BCP-47).
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   dump( char *tag, id value)
{
   NSString   *s;

   s = value ? [value description] : nil;
   mulle_printf( "%s=%s\n", tag, s ? [s UTF8String] : "(nil)");
}


static void   dumpBool( char *tag, id value)
{
   mulle_printf( "%s=%d\n", tag, value ? [value intValue] : -1);
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
      locale = [NSLocale localeWithLocaleIdentifier:@"de_DE.utf8"];
      dump( "de.countryCode", [locale countryCode]);
      dump( "de.scriptCode", [locale scriptCode]);
      dump( "de.collatorIdentifier", [locale objectForKey:NSLocaleCollatorIdentifier]);
      dump( "de.measurementSystem", [locale objectForKey:NSLocaleMeasurementSystem]);
      dumpBool( "de.usesMetricSystem", [locale objectForKey:NSLocaleUsesMetricSystem]);

      // the US is one of the three non-metric holdouts
      locale = [NSLocale localeWithLocaleIdentifier:@"en_US.utf8"];
      dump( "us.countryCode", [locale countryCode]);
      dump( "us.languageCode", [locale languageCode]);
      dump( "us.measurementSystem", [locale objectForKey:NSLocaleMeasurementSystem]);
      dumpBool( "us.usesMetricSystem", [locale objectForKey:NSLocaleUsesMetricSystem]);

      // an explicit script component
      locale = [NSLocale localeWithLocaleIdentifier:@"zh_Hans_CN"];
      dump( "zh.countryCode", [locale countryCode]);
      dump( "zh.scriptCode", [locale scriptCode]);
      dump( "zh.collatorIdentifier", [locale objectForKey:NSLocaleCollatorIdentifier]);

      // ... and the BCP-47 spelling of the same thing
      locale = [NSLocale localeWithLocaleIdentifier:@"zh-Hans-CN"];
      dump( "dash.countryCode", [locale countryCode]);
      dump( "dash.scriptCode", [locale scriptCode]);

      // no country at all
      locale = [NSLocale localeWithLocaleIdentifier:@"de"];
      dump( "bare.countryCode", [locale countryCode]);
      dump( "bare.collatorIdentifier", [locale objectForKey:NSLocaleCollatorIdentifier]);

      // An identifier the OS has no data for at all. Nothing here can come
      // from a system call, so it proves these keys are derived from the
      // identifier by the platform agnostic part of NSLocale.
      locale = [NSLocale localeWithLocaleIdentifier:@"xx_YY"];
      dump( "unknown.countryCode", [locale countryCode]);
      dump( "unknown.collatorIdentifier", [locale objectForKey:NSLocaleCollatorIdentifier]);
      dump( "unknown.measurementSystem", [locale objectForKey:NSLocaleMeasurementSystem]);
      dumpBool( "unknown.usesMetricSystem", [locale objectForKey:NSLocaleUsesMetricSystem]);

      // the C locale has neither country nor script
      locale = [NSLocale localeWithLocaleIdentifier:@"C"];
      dump( "c.countryCode", [locale countryCode]);
      dump( "c.scriptCode", [locale scriptCode]);
      dump( "c.measurementSystem", [locale objectForKey:NSLocaleMeasurementSystem]);
      dumpBool( "c.usesMetricSystem", [locale objectForKey:NSLocaleUsesMetricSystem]);
   }

   return( 0);
}

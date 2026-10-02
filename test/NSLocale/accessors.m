//
//  accessors.m
//  MulleObjCOSFoundation
//
//  Regression test: NSLocale has no -collatorIdentifier, -measurementSystem or
//  -usesMetricSystem accessor, so these values were only reachable through the
//  (untyped) -objectForKey:. They must agree with the keys they shortcut.
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   dump( char *tag, NSString *s)
{
   mulle_printf( "%s=%s\n", tag, s ? [s UTF8String] : "(nil)");
}


static void   dumpBool( char *tag, BOOL value)
{
   mulle_printf( "%s=%d\n", tag, value ? 1 : 0);
}


static BOOL   agrees( NSLocale *locale)
{
   if( ! [[locale collatorIdentifier] isEqualToString:[locale objectForKey:NSLocaleCollatorIdentifier]])
      return( NO);
   if( ! [[locale measurementSystem] isEqualToString:[locale objectForKey:NSLocaleMeasurementSystem]])
      return( NO);
   return( [locale usesMetricSystem] == [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue]);
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
      // no codeset, so the same test works on Linux (de_DE.UTF-8) and
      // Darwin/BSD (de_DE.UTF-8) alike
      locale = [NSLocale localeWithLocaleIdentifier:@"de_DE"];
      dump( "de.collatorIdentifier", [locale collatorIdentifier]);
      dump( "de.measurementSystem", [locale measurementSystem]);
      dumpBool( "de.usesMetricSystem", [locale usesMetricSystem]);
      dumpBool( "de.agrees", agrees( locale));

      locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
      dump( "us.collatorIdentifier", [locale collatorIdentifier]);
      dump( "us.measurementSystem", [locale measurementSystem]);
      dumpBool( "us.usesMetricSystem", [locale usesMetricSystem]);

      locale = [NSLocale localeWithLocaleIdentifier:@"C"];
      dump( "c.collatorIdentifier", [locale collatorIdentifier]);
      dump( "c.measurementSystem", [locale measurementSystem]);
      dumpBool( "c.usesMetricSystem", [locale usesMetricSystem]);
   }

   return( 0);
}

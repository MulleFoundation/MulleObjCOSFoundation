//
//  canonical.m
//  MulleObjCOSFoundation
//
//  Regression test: +canonicalLocaleIdentifierFromString: and
//  +canonicalLanguageIdentifierFromString: were declared on NSLocale but
//  implemented nowhere. Canonicalization normalizes the component case and
//  the separator to the POSIX "language[_script][_country][@modifier]" shape.
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   dump( char *tag, id value)
{
   NSString   *s;

   s = value ? [value description] : nil;
   mulle_printf( "%s=%s\n", tag, s ? [s UTF8String] : "(nil)");
}


int   main( int argc, const char * argv[])
{
#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      dump( "en-US", [NSLocale canonicalLocaleIdentifierFromString:@"en-US"]);
      dump( "EN-us", [NSLocale canonicalLocaleIdentifierFromString:@"EN-us"]);
      dump( "zh-hans-cn", [NSLocale canonicalLocaleIdentifierFromString:@"zh-hans-cn"]);
      dump( "de_DE.utf8", [NSLocale canonicalLocaleIdentifierFromString:@"de_DE.utf8"]);
      dump( "de_DE@euro", [NSLocale canonicalLocaleIdentifierFromString:@"de_DE@euro"]);

      dump( "lang-en-US", [NSLocale canonicalLanguageIdentifierFromString:@"en-US"]);
      dump( "lang-ZH", [NSLocale canonicalLanguageIdentifierFromString:@"ZH"]);
      dump( "lang-de", [NSLocale canonicalLanguageIdentifierFromString:@"de_DE"]);
   }

   return( 0);
}

//
//  components.m
//  MulleObjCOSFoundation
//
//  Regression test: +componentsFromLocaleIdentifier: and
//  +localeIdentifierFromComponents: were declared on NSLocale but implemented
//  nowhere, so any caller got an "unknown method" universe error.
//
//  The identifier grammar is "language[_script][_country][.codeset][@modifier]"
//  with "-" tolerated as a separator (BCP-47). A four letter component after
//  the language is a script. The codeset is not a locale component and is
//  dropped.
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
   NSDictionary   *components;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      components = [NSLocale componentsFromLocaleIdentifier:@"en_US"];
      dump( "en_US.languageCode", [components objectForKey:NSLocaleLanguageCode]);
      dump( "en_US.countryCode", [components objectForKey:NSLocaleCountryCode]);
      dump( "en_US.scriptCode", [components objectForKey:NSLocaleScriptCode]);

      components = [NSLocale componentsFromLocaleIdentifier:@"zh-Hans-CN"];
      dump( "zh.languageCode", [components objectForKey:NSLocaleLanguageCode]);
      dump( "zh.scriptCode", [components objectForKey:NSLocaleScriptCode]);
      dump( "zh.countryCode", [components objectForKey:NSLocaleCountryCode]);

      components = [NSLocale componentsFromLocaleIdentifier:@"de_DE.utf8@euro"];
      dump( "de.countryCode", [components objectForKey:NSLocaleCountryCode]);
      dump( "de.variantCode", [components objectForKey:NSLocaleVariantCode]);

      components = [NSLocale componentsFromLocaleIdentifier:@"de"];
      dump( "bare.languageCode", [components objectForKey:NSLocaleLanguageCode]);
      dump( "bare.countryCode", [components objectForKey:NSLocaleCountryCode]);

      dump( "nil", [NSLocale componentsFromLocaleIdentifier:nil]);
      dump( "empty.count", [NSNumber numberWithUnsignedInteger:
                              [[NSLocale componentsFromLocaleIdentifier:@""] count]]);

      dump( "zh.identifier", [NSLocale localeIdentifierFromComponents:
         [NSDictionary dictionaryWithObjectsAndKeys:
            @"zh", NSLocaleLanguageCode,
            @"Hans", NSLocaleScriptCode,
            @"CN", NSLocaleCountryCode,
            nil]]);
      dump( "de.identifier", [NSLocale localeIdentifierFromComponents:
         [NSDictionary dictionaryWithObjectsAndKeys:
            @"de", NSLocaleLanguageCode,
            @"DE", NSLocaleCountryCode,
            @"euro", NSLocaleVariantCode,
            nil]]);
      dump( "bare.identifier", [NSLocale localeIdentifierFromComponents:
         [NSDictionary dictionaryWithObject:@"en" forKey:NSLocaleLanguageCode]]);
      dump( "empty.identifier", [NSLocale localeIdentifierFromComponents:
         [NSDictionary dictionary]]);

      dump( "roundtrip", [NSLocale localeIdentifierFromComponents:
         [NSLocale componentsFromLocaleIdentifier:@"zh-Hans-CN"]]);
   }

   return( 0);
}

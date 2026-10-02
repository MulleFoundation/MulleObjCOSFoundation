//
//  variants.m
//  MulleObjCOSFoundation
//
//  Regression test: the identifier parser used to call *any* four letter
//  component after the language a script, which mis-read a numeric base
//  variant ("de_DE_1901") as a script and dropped uppercase base variants
//  ("en_US_POSIX", "ca_ES_VALENCIA") altogether. It also read the "u" of a
//  BCP-47 extension ("en-US-u-ca-gregory") as the country.
//
//  A script is four *alphabetic* letters, a variant is four digits or an
//  all-uppercase token, a country is two letters or three digits, and a lone
//  lowercase letter opens an extension sequence that is not a locale
//  component.
//
//  This only uses the platform agnostic +componentsFromLocaleIdentifier: and
//  +localeIdentifierFromComponents:, so the same output is expected on every
//  platform.
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
      // a four digit base component is a variant, not a script
      components = [NSLocale componentsFromLocaleIdentifier:@"de_DE_1901"];
      dump( "1901.language", [components objectForKey:NSLocaleLanguageCode]);
      dump( "1901.script", [components objectForKey:NSLocaleScriptCode]);
      dump( "1901.country", [components objectForKey:NSLocaleCountryCode]);
      dump( "1901.variant", [components objectForKey:NSLocaleVariantCode]);

      // ... and an all-uppercase token is one as well
      components = [NSLocale componentsFromLocaleIdentifier:@"en_US_POSIX"];
      dump( "posix.script", [components objectForKey:NSLocaleScriptCode]);
      dump( "posix.country", [components objectForKey:NSLocaleCountryCode]);
      dump( "posix.variant", [components objectForKey:NSLocaleVariantCode]);

      components = [NSLocale componentsFromLocaleIdentifier:@"ca_ES_VALENCIA"];
      dump( "valencia.country", [components objectForKey:NSLocaleCountryCode]);
      dump( "valencia.variant", [components objectForKey:NSLocaleVariantCode]);

      // a four letter alphabetic component still is a script
      components = [NSLocale componentsFromLocaleIdentifier:@"sr_Latn_RS"];
      dump( "script.script", [components objectForKey:NSLocaleScriptCode]);
      dump( "script.country", [components objectForKey:NSLocaleCountryCode]);
      dump( "script.variant", [components objectForKey:NSLocaleVariantCode]);

      // a BCP-47 extension sequence is not a country
      components = [NSLocale componentsFromLocaleIdentifier:@"en-US-u-ca-gregory"];
      dump( "bcext.language", [components objectForKey:NSLocaleLanguageCode]);
      dump( "bcext.script", [components objectForKey:NSLocaleScriptCode]);
      dump( "bcext.country", [components objectForKey:NSLocaleCountryCode]);
      dump( "bcext.variant", [components objectForKey:NSLocaleVariantCode]);

      components = [NSLocale componentsFromLocaleIdentifier:@"zh-Hant-TW-u-ca-chinese"];
      dump( "bcext2.script", [components objectForKey:NSLocaleScriptCode]);
      dump( "bcext2.country", [components objectForKey:NSLocaleCountryCode]);
      dump( "bcext2.variant", [components objectForKey:NSLocaleVariantCode]);

      // writing a base variant back uses "_", a "@modifier" stays "@"
      dump( "posix.identifier", [NSLocale localeIdentifierFromComponents:
         [NSDictionary dictionaryWithObjectsAndKeys:
            @"en", NSLocaleLanguageCode,
            @"US", NSLocaleCountryCode,
            @"POSIX", NSLocaleVariantCode,
            nil]]);
      dump( "1901.identifier", [NSLocale localeIdentifierFromComponents:
         [NSDictionary dictionaryWithObjectsAndKeys:
            @"de", NSLocaleLanguageCode,
            @"DE", NSLocaleCountryCode,
            @"1901", NSLocaleVariantCode,
            nil]]);
      dump( "euro.identifier", [NSLocale localeIdentifierFromComponents:
         [NSDictionary dictionaryWithObjectsAndKeys:
            @"de", NSLocaleLanguageCode,
            @"DE", NSLocaleCountryCode,
            @"euro", NSLocaleVariantCode,
            nil]]);

      // and a base variant survives a components round trip
      dump( "roundtrip", [NSLocale localeIdentifierFromComponents:
         [NSLocale componentsFromLocaleIdentifier:@"en_US_POSIX"]]);
   }

   return( 0);
}

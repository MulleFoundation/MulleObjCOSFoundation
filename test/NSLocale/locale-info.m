//
//  locale-info.m
//  MulleObjCOSFoundation
//
//  Regression test: -objectForKey: must actually return locale information.
//  The Linux backend ignored the QUERY_INFO and CONV_INFO key classes that
//  mulle_locale_map_string_key_to_local_key() produces, so every locale
//  looked completely empty.
//
//  Only portable facts are asserted. The exact separators and the currency of
//  the "C" locale are not portable (the Windows invariant locale has "," "¤"
//  and "XDR"), but that a decimal separator exists, that the CONV keys are
//  answered at all, and that -currencyCode is a shortcut for
//  objectForKey:NSLocaleCurrencyCode, are the same everywhere.
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   dumpBool( char *tag, BOOL flag)
{
   mulle_printf( "%s=%s\n", tag, flag ? "YES" : "NO");
}


int   main( int argc, const char * argv[])
{
   NSLocale     *locale;
   NSString     *decimalSeparator;
   NSString     *currencyCode;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      locale           = [NSLocale localeWithLocaleIdentifier:@"C"];
      decimalSeparator = [locale objectForKey:NSLocaleDecimalSeparator];
      currencyCode     = [locale currencyCode];

      // every locale has a decimal separator
      dumpBool( "decimalSeparator-nonempty", [decimalSeparator length] != 0);
      // and the remaining CONV keys must at least be answered
      dumpBool( "groupingSeparator-answered", [locale objectForKey:NSLocaleGroupingSeparator] != nil);
      dumpBool( "currencySymbol-answered", [locale objectForKey:NSLocaleCurrencySymbol] != nil);
      dumpBool( "currencyCode-answered", currencyCode != nil);

      // -languageCode follows from the identifier
      dumpBool( "languageCode-is-C", [[locale languageCode] isEqualToString:@"C"]);

      // -currencyCode must be a shortcut for objectForKey:NSLocaleCurrencyCode
      dumpBool( "currencyCode-matches", [currencyCode isEqualToString:[locale objectForKey:NSLocaleCurrencyCode]]);
   }

   return( 0);
}

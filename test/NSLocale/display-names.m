//
//  display-names.m
//  MulleObjCOSFoundation
//
//  Regression test: -displayNameForKey:value: used to be a 12 entry English
//  table that answered only for an "en" receiver and only for
//  NSLocaleLanguageCode. It now answers the CLDR English names for languages,
//  countries, scripts and variants, from tables generated at development time
//  (ICU is not a dependency of the product).
//
//  The fallback is load bearing and is asserted here: a code no table knows,
//  and every key that has no name table at all, come back as the value
//  *unchanged*. NSBundle builds a "<name>.lproj" directory out of
//  localizedStringForLanguageCode:, so an unknown language must not become nil.
//
//  A receiver that is not English answers the English name as well: that is
//  the only name language there is.
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   dump( char *tag, NSString *s)
{
   mulle_printf( "%s=%s\n", tag, s ? [s UTF8String] : "(nil)");
}


// Prints the length and the non-ASCII code points of a name. The tables store
// the names with \uXXXX escapes, and this proves they decoded to the right
// characters while keeping the golden file pure ASCII.
static void   dumpNonASCII( char *tag, NSString *s)
{
   unichar      c;
   NSUInteger   i;
   NSUInteger   n;
   BOOL         first;

   if( ! s)
   {
      mulle_printf( "%s=(nil)\n", tag);
      return;
   }

   mulle_printf( "%s=length:%lu", tag, (unsigned long) [s length]);
   first = YES;
   n     = [s length];
   for( i = 0; i < n; i++)
   {
      c = [s characterAtIndex:i];
      if( c < 0x80)
         continue;
      mulle_printf( "%sU+%04X", first ? " " : ",", c);
      first = NO;
   }
   mulle_printf( "\n");
}


int   main( int argc, const char * argv[])
{
   NSLocale   *english;
   NSLocale   *german;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      english = [NSLocale localeWithLocaleIdentifier:@"en_US"];

      dump( "lang.de", [english localizedStringForLanguageCode:@"de"]);
      dump( "lang.zh", [english localizedStringForLanguageCode:@"zh"]);
      // not a language code -> verbatim
      dump( "lang.xx", [english localizedStringForLanguageCode:@"xx"]);

      dump( "country.DE", [english localizedStringForCountryCode:@"DE"]);
      dump( "country.JP", [english localizedStringForCountryCode:@"JP"]);
      dump( "country.ZZ", [english localizedStringForCountryCode:@"ZZ"]);

      dump( "script.Latn", [english localizedStringForScriptCode:@"Latn"]);
      dump( "script.Cyrl", [english localizedStringForScriptCode:@"Cyrl"]);
      dump( "script.Zzzz", [english localizedStringForScriptCode:@"Zzzz"]);

      dump( "variant.POSIX", [english localizedStringForVariantCode:@"POSIX"]);
      dump( "variant.VALENCIA", [english localizedStringForVariantCode:@"VALENCIA"]);
      dump( "variant.NOPE", [english localizedStringForVariantCode:@"NOPE"]);

      // the code is matched case insensitively, the table is stored folded
      dump( "case.lang", [english displayNameForKey:NSLocaleLanguageCode value:@"DE"]);
      dump( "case.country", [english displayNameForKey:NSLocaleCountryCode value:@"de"]);
      dump( "case.script", [english displayNameForKey:NSLocaleScriptCode value:@"latn"]);

      // a code with extra parts still names the first component
      dump( "parts.lang", [english displayNameForKey:NSLocaleLanguageCode value:@"zh-Hans"]);

      // no name table at all -> the value verbatim
      dump( "identifier", [english displayNameForKey:NSLocaleIdentifier value:@"de_DE"]);
      dump( "currency", [english displayNameForKey:NSLocaleCurrencyCode value:@"EUR"]);

      // a name with non-ASCII in it ("Cote d'Ivoire" with a circumflex and a
      // curly apostrophe): the tables store these as \uXXXX escapes
      dumpNonASCII( "country.CI", [english localizedStringForCountryCode:@"CI"]);
      dumpNonASCII( "country.AX", [english localizedStringForCountryCode:@"AX"]);

      // a receiver that is not English answers the names we do have
      german = [NSLocale localeWithLocaleIdentifier:@"de_DE"];
      dump( "german.lang.fr", [german localizedStringForLanguageCode:@"fr"]);
      dump( "german.country.FR", [german localizedStringForCountryCode:@"FR"]);
   }

   return( 0);
}

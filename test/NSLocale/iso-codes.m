//
//  iso-codes.m
//  MulleObjCOSFoundation
//
//  Regression test: +ISOLanguageCodes, +ISOCountryCodes and +ISOCurrencyCodes
//  were declared on NSLocale but implemented nowhere. They are derived from
//  +availableLocaleIdentifiers, so they only contain codes this host can
//  serve. Which locales are installed is deliberately not asserted, only that
//  the result is ISO shaped, duplicate free and covers every code that the
//  available locales actually mention.
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static BOOL   isISOShape( NSString *s, NSUInteger min, NSUInteger max, BOOL uppercase)
{
   unichar    c;
   NSUInteger i;
   NSUInteger n;

   if( ! s || ! [s isKindOfClass:[NSString class]])
      return( NO);

   n = [s length];
   if( n < min || n > max)
      return( NO);

   for( i = 0; i < n; i++)
   {
      c = [s characterAtIndex:i];
      if( uppercase)
      {
         if( c < 'A' || c > 'Z')
            return( NO);
      }
      else
      {
         if( c < 'a' || c > 'z')
            return( NO);
      }
   }
   return( YES);
}


static BOOL   allShape( NSArray *codes, NSUInteger min, NSUInteger max, BOOL uppercase)
{
   NSString   *code;
   NSUInteger i;
   NSUInteger n;

   n = [codes count];
   for( i = 0; i < n; i++)
   {
      code = [codes objectAtIndex:i];
      if( ! isISOShape( code, min, max, uppercase))
         return( NO);
   }
   return( YES);
}


static BOOL   allUnique( NSArray *codes)
{
   NSString   *code;
   NSUInteger i;
   NSUInteger n;

   n = [codes count];
   for( i = 0; i < n; i++)
   {
      code = [codes objectAtIndex:i];
      if( [codes indexOfObject:code] != i)
         return( NO);
   }
   return( YES);
}


static void   dump( char *tag, BOOL flag)
{
   mulle_printf( "%s=%s\n", tag, flag ? "YES" : "NO");
}


int   main( int argc, const char * argv[])
{
   NSArray        *available;
   NSArray        *languages;
   NSArray        *countries;
   NSArray        *currencies;
   NSDictionary   *components;
   NSLocale       *locale;
   NSString       *identifier;
   NSString       *code;
   NSUInteger     i;
   NSUInteger     n;
   BOOL           coverLanguages;
   BOOL           coverCountries;
   BOOL           coverCurrencies;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      available  = [NSLocale availableLocaleIdentifiers];
      languages  = [NSLocale ISOLanguageCodes];
      countries  = [NSLocale ISOCountryCodes];
      currencies = [NSLocale ISOCurrencyCodes];

      dump( "languages-shape", languages && allShape( languages, 2, 3, NO));
      dump( "countries-shape", countries && allShape( countries, 2, 2, YES));
      dump( "currencies-shape", currencies && allShape( currencies, 3, 3, YES));

      dump( "languages-unique", languages && allUnique( languages));
      dump( "countries-unique", countries && allUnique( countries));
      dump( "currencies-unique", currencies && allUnique( currencies));

      coverLanguages  = YES;
      coverCountries  = YES;
      coverCurrencies = YES;
      n               = [available count];
      for( i = 0; i < n; i++)
      {
         identifier = [available objectAtIndex:i];
         if( ! [identifier isKindOfClass:[NSString class]])
            continue;

         components = [NSLocale componentsFromLocaleIdentifier:identifier];

         code = [[components objectForKey:NSLocaleLanguageCode] lowercaseString];
         if( isISOShape( code, 2, 3, NO) && ! [languages containsObject:code])
            coverLanguages = NO;

         code = [[components objectForKey:NSLocaleCountryCode] uppercaseString];
         if( isISOShape( code, 2, 2, YES) && ! [countries containsObject:code])
            coverCountries = NO;

         // legacy encoded locales carry monetary data that is not UTF-8 and
         // must not abort the process when it is read
         locale = [NSLocale localeWithLocaleIdentifier:identifier];
         code   = [[locale currencyCode] uppercaseString];

         if( isISOShape( code, 3, 3, YES) && ! [currencies containsObject:code])
            coverCurrencies = NO;
      }

      dump( "languages-cover", coverLanguages);
      dump( "countries-cover", coverCountries);
      dump( "currencies-cover", coverCurrencies);
   }

   return( 0);
}

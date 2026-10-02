//
//  preferred-languages.m
//  MulleObjCOSFoundation
//
//  Regression test: +preferredLanguages reads the environment (there is no
//  user defaults layer this low down). LANGUAGE is the preference list and can
//  name more than one language, so it is set explicitly to check the order,
//  the dropping of codeset/modifier and the deduplication. Without a language
//  the list must still not be empty.
//
//  POSIX setenv/unsetenv do not exist on Windows, which spells this
//  differently (same trick as the NSTimeZone test).
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   setLanguage( char *value)
{
#ifdef _WIN32
   if( value)
      _putenv_s( "LANGUAGE", value);
   else
      _putenv( "LANGUAGE=");
#else
   if( value)
      setenv( "LANGUAGE", value, 1);
   else
      unsetenv( "LANGUAGE");
#endif
}


static void   dump( char *tag, NSArray *languages)
{
   NSString   *language;
   NSUInteger i;
   NSUInteger n;

   n = [languages count];
   mulle_printf( "%s=%lu", tag, (unsigned long) n);
   for( i = 0; i < n; i++)
   {
      language = [languages objectAtIndex:i];
      mulle_printf( " %s", [language UTF8String]);
   }
   mulle_printf( "\n");
}


int   main( int argc, const char * argv[])
{
   NSArray   *languages;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      // a priority list with a codeset and a modifier that must be dropped and
      // a duplicate that must be folded
      setLanguage( "fr:de_DE.UTF-8@euro:fr");
      dump( "languages", [NSLocale preferredLanguages]);

      // empty entries are skipped
      setLanguage( "::ja:");
      dump( "single", [NSLocale preferredLanguages]);

      // no language at all: the list is never empty
      setLanguage( NULL);
      languages = [NSLocale preferredLanguages];
      mulle_printf( "fallback-count=%s\n",
                    [languages count] ? "ok" : "empty");
      mulle_printf( "fallback-string=%s\n",
                    [[languages objectAtIndex:0] isKindOfClass:[NSString class]]
                       ? "ok" : "bad");

      setLanguage( "en");
   }

   return( 0);
}

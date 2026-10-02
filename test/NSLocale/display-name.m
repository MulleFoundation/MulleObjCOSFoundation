//
//  display-name.m
//  MulleObjCOSFoundation
//
//  Regression test: -displayNameForKey:value: must know the *ISO 639-1* code
//  for Japanese, which is "ja". It consulted "jp" (a country code) instead, so
//  asking for the name of "ja" fell through and returned the code verbatim.
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   dump( char *tag, NSString *s)
{
   mulle_printf( "%s=%s\n", tag, s ? [s UTF8String] : "(nil)");
}


int   main( int argc, const char * argv[])
{
   NSLocale   *english;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      english = [NSLocale localeWithLocaleIdentifier:@"en_US"];

      dump( "de", [english displayNameForKey:NSLocaleLanguageCode value:@"de"]);
      dump( "ja", [english displayNameForKey:NSLocaleLanguageCode value:@"ja"]);
      // "jp" is a country code, not a language code, so it stays verbatim
      dump( "jp", [english displayNameForKey:NSLocaleLanguageCode value:@"jp"]);
      dump( "zh-Hans", [english displayNameForKey:NSLocaleLanguageCode value:@"zh-Hans"]);
      dump( "it", [english displayNameForKey:NSLocaleLanguageCode value:@"it"]);
      dump( "ru", [english displayNameForKey:NSLocaleLanguageCode value:@"ru"]);

      // a key we have no table for, and an unknown language code
      dump( "identifier", [english displayNameForKey:NSLocaleIdentifier value:@"de_DE"]);
      dump( "unknown", [english displayNameForKey:NSLocaleLanguageCode value:@"qq"]);

      // and through the shortcut, which must agree
      dump( "shortcut", [english localizedStringForLanguageCode:@"ja"]);
   }

   return( 0);
}

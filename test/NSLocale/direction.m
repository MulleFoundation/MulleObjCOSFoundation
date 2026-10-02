//
//  direction.m
//  MulleObjCOSFoundation
//
//  Regression test: +characterDirectionForLanguage: and
//  +lineDirectionForLanguage: classify the right-to-left languages and default
//  the others to left-to-right, purely from a hand-rolled table (no OS
//  backend). A code that is not a language we ship a name for answers Unknown,
//  as does nil. The two methods always answer the same.
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static char   *directionName( NSLocaleLanguageDirection direction)
{
   switch( direction)
   {
   case NSLocaleLanguageDirectionUnknown     : return( "unknown");
   case NSLocaleLanguageDirectionLeftToRight : return( "ltr");
   case NSLocaleLanguageDirectionRightToLeft : return( "rtl");
   case NSLocaleLanguageDirectionTopToBottom : return( "ttb");
   case NSLocaleLanguageDirectionBottomToTop : return( "btt");
   }
   return( "?");
}


static void   show( char *tag, NSLocaleLanguageDirection direction)
{
   mulle_printf( "%s=%s\n", tag, directionName( direction));
}


int   main( int argc, const char * argv[])
{
#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      // right to left languages and a legacy ISO 639-1 alias
      show( "ar", [NSLocale characterDirectionForLanguage:@"ar"]);
      show( "he", [NSLocale characterDirectionForLanguage:@"he"]);
      show( "fa", [NSLocale characterDirectionForLanguage:@"fa"]);
      show( "ur", [NSLocale characterDirectionForLanguage:@"ur"]);
      show( "ckb", [NSLocale characterDirectionForLanguage:@"ckb"]);
      show( "iw", [NSLocale characterDirectionForLanguage:@"iw"]);

      // left to right languages (ku defaults to a Latin script)
      show( "en", [NSLocale characterDirectionForLanguage:@"en"]);
      show( "de", [NSLocale characterDirectionForLanguage:@"de"]);
      show( "zh", [NSLocale characterDirectionForLanguage:@"zh"]);
      show( "ru", [NSLocale characterDirectionForLanguage:@"ru"]);
      show( "ku", [NSLocale characterDirectionForLanguage:@"ku"]);

      // case folded
      show( "EN", [NSLocale characterDirectionForLanguage:@"EN"]);

      // not a language we know
      show( "zz", [NSLocale characterDirectionForLanguage:@"zz"]);
      show( "toolong", [NSLocale characterDirectionForLanguage:@"toolong"]);
      show( "nil", [NSLocale characterDirectionForLanguage:nil]);

      // line direction answers the same
      show( "line-ar", [NSLocale lineDirectionForLanguage:@"ar"]);
      show( "line-en", [NSLocale lineDirectionForLanguage:@"en"]);
      show( "line-nil", [NSLocale lineDirectionForLanguage:nil]);
   }

   return( 0);
}

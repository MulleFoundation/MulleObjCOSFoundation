//
//  locale-identifier.m
//  MulleObjCOSFoundation
//
//  Regression test: -initWithLocaleIdentifier: must not return nil. POSIX
//  newlocale() insists on an explicit codeset, so an identifier like "en_US"
//  (which is perfectly valid, just without a codeset) used to fail and yield
//  nil. A NSLocale is never expected to be nil, not even for an unknown
//  identifier.
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   dump( char *tag, NSLocale *locale)
{
   if( ! locale)
   {
      mulle_printf( "%s=nil\n", tag);
      return;
   }

   mulle_printf( "%s=ok\n", tag);
   mulle_printf( "%s.identifier=%s\n", tag, [[locale localeIdentifier] UTF8String]);
}


static void   dumpString( char *tag, NSString *s)
{
   mulle_printf( "%s=%s\n", tag, s ? [s UTF8String] : "(nil)");
}


int   main( int argc, const char * argv[])
{
   NSLocale   *en;
   NSLocale   *unknown;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      // no codeset, but en_US is installed as en_US.UTF-8
      en      = [NSLocale localeWithLocaleIdentifier:@"en_US"];
      // not installed at all, must still yield a usable locale
      unknown = [NSLocale localeWithLocaleIdentifier:@"xx_YY"];

      dump( "en_US", en);
      dumpString( "en_US.languageCode", en ? [en languageCode] : nil);
      dump( "xx_YY", unknown);
   }

   return( 0);
}

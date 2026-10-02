//
//  collation-identifier.m
//  MulleObjCOSFoundation
//
//  Regression test: NSLocaleCollationIdentifier used to disagree per backend.
//  Linux answered the POSIX "@modifier", BSD answered querylocale(LC_COLLATE)
//  (a locale name) and Windows answered nil. Apple defines it as the value of
//  the "@collation=..." keyword of the identifier, or nil when there is none.
//  That follows from the identifier alone, so it is now derived platform
//  independently and every backend gives the same answer.
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   dump( char *tag, id value)
{
   NSString   *s;

   s = value ? [value description] : nil;
   mulle_printf( "%s=%s\n", tag, s ? [s UTF8String] : "(nil)");
}


static void   dumpBool( char *tag, BOOL flag)
{
   mulle_printf( "%s=%s\n", tag, flag ? "YES" : "NO");
}


// -collationIdentifier must be a shortcut for objectForKey:NSLocaleCollationIdentifier
static BOOL   agrees( NSLocale *locale)
{
   NSString   *a;
   NSString   *b;

   a = [locale collationIdentifier];
   b = [locale objectForKey:NSLocaleCollationIdentifier];
   if( ! a && ! b)
      return( YES);
   if( ! a || ! b)
      return( NO);
   return( [a isEqualToString:b]);
}


int   main( int argc, const char * argv[])
{
   NSLocale   *locale;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      // a plain locale has no collation keyword
      locale = [NSLocale localeWithLocaleIdentifier:@"de_DE"];
      dump( "plain", [locale objectForKey:NSLocaleCollationIdentifier]);
      dumpBool( "plain.agrees", agrees( locale));

      // a POSIX "@euro" modifier is not a collation
      locale = [NSLocale localeWithLocaleIdentifier:@"de_DE@euro"];
      dump( "modifier", [locale objectForKey:NSLocaleCollationIdentifier]);

      // the ICU collation keyword is what is wanted
      locale = [NSLocale localeWithLocaleIdentifier:@"en_US@collation=phonebook"];
      dump( "collation", [locale objectForKey:NSLocaleCollationIdentifier]);
      dump( "collation.accessor", [locale collationIdentifier]);
      dumpBool( "collation.agrees", agrees( locale));

      // ... also when it is not the only keyword
      locale = [NSLocale localeWithLocaleIdentifier:@"de_DE@collation=phonebook;calendar=gregorian"];
      dump( "multi", [locale objectForKey:NSLocaleCollationIdentifier]);

      // a script component is not a collation either
      locale = [NSLocale localeWithLocaleIdentifier:@"zh_Hans_CN"];
      dump( "script", [locale objectForKey:NSLocaleCollationIdentifier]);

      locale = [NSLocale localeWithLocaleIdentifier:@"C"];
      dump( "c", [locale objectForKey:NSLocaleCollationIdentifier]);
   }

   return( 0);
}

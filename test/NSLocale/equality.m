//
//  equality.m
//  MulleObjCOSFoundation
//
//  Regression test: -isEqual: and -hash compared and hashed the raw
//  identifier, so "en_US", "en-US" and "en_US.UTF-8" were three *different*
//  locales - three different set members and three different dictionary keys
//  for the same thing. They now go through
//  +canonicalLocaleIdentifierFromString:, which normalizes the separator, the
//  component case and drops the ".codeset".
//
//  -localeIdentifier still answers what the receiver was created with. That is
//  a deliberate choice (see NSLocale.h), and it is why two equal locales can
//  report different identifiers: [locale localeIdentifier] as a key is not the
//  same as the locale itself as a key.
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   dumpBool( char *tag, BOOL flag)
{
   mulle_printf( "%s=%s\n", tag, flag ? "YES" : "NO");
}


static BOOL   equal( NSString *a, NSString *b)
{
   NSLocale   *x;
   NSLocale   *y;
   BOOL       result;

   x      = [NSLocale localeWithLocaleIdentifier:a];
   y      = [NSLocale localeWithLocaleIdentifier:b];
   result = [x isEqual:y];

   // equal objects must have equal hashes
   if( result && [x hash] != [y hash])
      return( NO);
   return( result);
}


int   main( int argc, const char * argv[])
{
   NSLocale       *locale;
   NSMutableSet   *set;
   NSDictionary   *dict;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      dumpBool( "en_US=en-US", equal( @"en_US", @"en-US"));
      dumpBool( "en_US=en_US.UTF-8", equal( @"en_US", @"en_US.UTF-8"));
      dumpBool( "zh_Hans_CN=zh-hans-cn", equal( @"zh_Hans_CN", @"zh-hans-cn"));
      dumpBool( "en_US=de_DE", equal( @"en_US", @"de_DE"));
      dumpBool( "de_DE=de_DE@euro", equal( @"de_DE", @"de_DE@euro"));

      locale = [NSLocale localeWithLocaleIdentifier:@"en-US"];
      mulle_printf( "identifier=%s\n", [[locale localeIdentifier] UTF8String]);

      // ... so this has to look at the canonical form, not at the identifier
      dumpBool( "isEqualToLocale",
                [[NSLocale localeWithLocaleIdentifier:@"en_US"] isEqualToLocale:locale]);

      // equal locales are one set member ...
      set = [NSMutableSet set];
      [set addObject:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
      [set addObject:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
      [set addObject:[NSLocale localeWithLocaleIdentifier:@"en_US.UTF-8"]];
      mulle_printf( "set-count=%lu\n", (unsigned long) [set count]);

      // ... and one dictionary key
      dict = [NSDictionary dictionaryWithObject:@"found"
                                         forKey:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
      mulle_printf( "dict-lookup=%s\n",
                    [dict objectForKey:[NSLocale localeWithLocaleIdentifier:@"en-US"]] ?
                       "found" : "(nil)");
   }

   return( 0);
}

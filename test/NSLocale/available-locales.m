//
//  available-locales.m
//  MulleObjCOSFoundation
//
//  Regression test: +availableLocaleIdentifiers must return a usable list of
//  identifiers. It may not contain an empty entry (the POSIX implementation
//  forgot to drop the trailing newline of "locale -a", which produced one) and
//  every returned identifier must round-trip unchanged through
//  -initWithLocaleIdentifier:.
//
//  Which locales a platform has installed is deliberately not asserted, that
//  is not portable.
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   dump( char *tag, BOOL flag)
{
   mulle_printf( "%s=%s\n", tag, flag ? "YES" : "NO");
}


int   main( int argc, const char * argv[])
{
   NSArray      *identifiers;
   NSLocale     *locale;
   NSString     *identifier;
   NSUInteger   i;
   NSUInteger   n;
   BOOL         hasEmpty;
   BOOL         roundTrips;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      identifiers = [NSLocale availableLocaleIdentifiers];

      hasEmpty   = NO;
      roundTrips = YES;
      n          = [identifiers count];
      for( i = 0; i < n; i++)
      {
         identifier = [identifiers objectAtIndex:i];
         if( ! [identifier isKindOfClass:[NSString class]] || ! [identifier length])
         {
            hasEmpty = YES;
            continue;
         }

         locale = [NSLocale localeWithLocaleIdentifier:identifier];
         if( ! [[locale localeIdentifier] isEqualToString:identifier])
            roundTrips = NO;
      }

      dump( "has-empty", hasEmpty);
      dump( "non-empty", n != 0);
      dump( "all-roundtrip", roundTrips);
   }

   return( 0);
}

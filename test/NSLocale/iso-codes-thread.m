//
//  iso-codes-thread.m
//  MulleObjCOSFoundation
//
//  Regression test: +ISOLanguageCodes, +ISOCountryCodes and +ISOCurrencyCodes
//  are built lazily and cached in a class level (static) structure the first
//  time any thread asks for them. This races that cold path: several threads
//  hit the three methods at once and every thread must still observe the same,
//  non-empty result (the cache must never hand back a half built list).
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


#define THREADS   4


static NSArray   *LanguageCodes[ THREADS];
static NSArray   *CountryCodes[ THREADS];
static NSArray   *CurrencyCodes[ THREADS];


@interface NSLocaleISOCodesTester : NSObject
@end


@implementation NSLocaleISOCodesTester

// Runs on a secondary thread. The thread index is passed as the object, so
// each thread writes its own slot and there is no race in the test itself.
+ (void) test:(id) indexObject
{
   NSUInteger   index;

   index = [indexObject unsignedIntegerValue];

   @autoreleasepool
   {
      LanguageCodes[ index] = [NSLocale ISOLanguageCodes];
      CountryCodes[ index]  = [NSLocale ISOCountryCodes];
      CurrencyCodes[ index] = [NSLocale ISOCurrencyCodes];
   }
}

@end


int   main( int argc, char *argv[])
{
   NSThread   *threads[ THREADS];
   NSUInteger i;
   BOOL       same;
   BOOL       nonEmpty;

#if defined( __MULLE_OBJC__)
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      for( i = 0; i < THREADS; i++)
         threads[ i] = [[[NSThread alloc] initWithTarget:[NSLocaleISOCodesTester class]
                                                selector:@selector( test:)
                                                  object:[NSNumber numberWithUnsignedInteger:i]] autorelease];

      for( i = 0; i < THREADS; i++)
         [threads[ i] mulleStart];
      for( i = 0; i < THREADS; i++)
         [threads[ i] mulleJoin];

      same = YES;
      for( i = 1; i < THREADS; i++)
      {
         if( ! [LanguageCodes[ 0] isEqual:LanguageCodes[ i]])
            same = NO;
         if( ! [CountryCodes[ 0] isEqual:CountryCodes[ i]])
            same = NO;
         if( ! [CurrencyCodes[ 0] isEqual:CurrencyCodes[ i]])
            same = NO;
      }

      nonEmpty = [LanguageCodes[ 0] count] &&
                 [CountryCodes[ 0] count] &&
                 [CurrencyCodes[ 0] count];

      mulle_printf( "codes-same=%s\n", same ? "YES" : "NO");
      mulle_printf( "codes-nonempty=%s\n", nonEmpty ? "YES" : "NO");
   }

   return( 0);
}

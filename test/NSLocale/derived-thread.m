//
//  derived-thread.m
//  MulleObjCOSFoundation
//
//  Regression test: the keys that follow from the locale identifier
//  (identifier, languageCode, scriptCode, countryCode, variantCode,
//  collationIdentifier, collatorIdentifier, measurementSystem,
//  usesMetricSystem) are precomputed once, when the locale is created, into an
//  immutable dictionary that -objectForKey: reads without taking the locale's
//  lock. Several threads hammering those keys on one shared locale must always
//  see the very same objects: the lock free read must never hand back a half
//  built dictionary (nor one that is being mutated under their feet).
//
//  The workers compare *object identity*, not -isEqual:, on purpose. The
//  values are shared between threads by design, but a value that was created
//  on the thread that built the locale keeps that thread's TAO affinity, and
//  TAO aborts when such a value is messaged from another thread. That is a
//  property of the value (and of mulle-objc's TAO), not of this cache, and it
//  predates the cache: it is out of scope here.
//
//  A key that no source can answer must still come back nil - the "asked,
//  there is no value" sentinel must not leak out as NSNull.
//
//  Platform agnostic: "de_DE_1901" is a valid identifier everywhere, and the
//  values asserted here are derived from the identifier, not from the OS.
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


#define THREADS   4
#define ROUNDS    250
#define KEYS      9


static NSLocale   *SharedLocale;
static NSString   *DerivedKeys[ KEYS];   // filled in main, read only afterwards
static id         ExpectedValues[ KEYS]; // dito
static BOOL       ThreadFailed[ THREADS];


@interface NSLocaleDerivedTester : NSObject
@end


@implementation NSLocaleDerivedTester

// Runs on a secondary thread. The thread index is passed as the object, so
// each thread writes its own slot and there is no race in the test itself.
+ (void) test:(id) indexObject
{
   NSUInteger   index;
   NSUInteger   round;
   NSUInteger   i;

   index = [indexObject unsignedIntegerValue];

   @autoreleasepool
   {
      for( round = 0; round < ROUNDS; round++)
      {
         for( i = 0; i < KEYS; i++)
         {
            if( [SharedLocale objectForKey:DerivedKeys[ i]] != ExpectedValues[ i])
            {
               ThreadFailed[ index] = YES;
               return;
            }
         }

         if( [SharedLocale objectForKey:@"mulle-locale-unanswerable-key"])
         {
            ThreadFailed[ index] = YES;
            return;
         }
      }
   }
}

@end


int   main( int argc, char *argv[])
{
   NSThread   *threads[ THREADS];
   NSUInteger i;
   BOOL       consistent;
   id         unknown;

   DerivedKeys[ 0] = NSLocaleIdentifier;
   DerivedKeys[ 1] = NSLocaleLanguageCode;
   DerivedKeys[ 2] = NSLocaleScriptCode;
   DerivedKeys[ 3] = NSLocaleCountryCode;
   DerivedKeys[ 4] = NSLocaleVariantCode;
   DerivedKeys[ 5] = NSLocaleCollationIdentifier;
   DerivedKeys[ 6] = NSLocaleCollatorIdentifier;
   DerivedKeys[ 7] = NSLocaleMeasurementSystem;
   DerivedKeys[ 8] = NSLocaleUsesMetricSystem;

#if defined( __MULLE_OBJC__)
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      SharedLocale = [[NSLocale localeWithLocaleIdentifier:@"de_DE_1901"] retain];

      // capture the expected values on the main thread, before any thread runs
      for( i = 0; i < KEYS; i++)
         ExpectedValues[ i] = [SharedLocale objectForKey:DerivedKeys[ i]];

      for( i = 0; i < THREADS; i++)
         threads[ i] = [[[NSThread alloc] initWithTarget:[NSLocaleDerivedTester class]
                                                selector:@selector( test:)
                                                  object:[NSNumber numberWithUnsignedInteger:i]] autorelease];

      for( i = 0; i < THREADS; i++)
         [threads[ i] mulleStart];
      for( i = 0; i < THREADS; i++)
         [threads[ i] mulleJoin];

      consistent = YES;
      for( i = 0; i < THREADS; i++)
         if( ThreadFailed[ i])
            consistent = NO;

      // "de_DE_1901" has a language, a country and a variant, so these three
      // must be non-nil - a fast path that answered nothing would otherwise
      // pass the identity comparison above trivially (nil == nil).
      if( ! ExpectedValues[ 1] || ! ExpectedValues[ 3] || ! ExpectedValues[ 4])
         consistent = NO;

      unknown = [SharedLocale objectForKey:@"mulle-locale-unanswerable-key"];

      mulle_printf( "derived-consistent=%s\n", consistent ? "YES" : "NO");
      mulle_printf( "unknown-key=%s\n", unknown ? "SOME" : "nil");

      [SharedLocale release];
   }

   return( 0);
}

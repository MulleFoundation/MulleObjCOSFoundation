//
//  current-locale.m
//  MulleObjCOSFoundation
//
//  Regression test: +currentLocale must return the cached "current" locale,
//  not the cached "system" locale. +initialize() caches them as two distinct
//  objects, so returning the system locale both makes them indistinguishable
//  and short-circuits any +_currentLocale implementation.
//
//  Deliberately platform agnostic: it asserts the invariant only, not any
//  particular locale name, so it needs no per-platform expected output.
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


int   main( int argc, const char * argv[])
{
   NSLocale   *system;
   NSLocale   *current;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      system  = [NSLocale systemLocale];
      current = [NSLocale currentLocale];

      mulle_printf( "system=%s\n", system ? "ok" : "nil");
      mulle_printf( "current=%s\n", current ? "ok" : "nil");
      mulle_printf( "current-is-system=%s\n", current == system ? "YES" : "NO");
   }

   return( 0);
}

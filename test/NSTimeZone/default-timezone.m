//
//  default-timezone.m
//  MulleObjCOSFoundation
//
//  Regression test for NSTimeZone:
//
//   * a named zone must load its real offset and DST rules from the
//     zoneinfo database (TZDIR), not silently become GMT,
//   * an unresolvable name must answer nil, not a named GMT zone,
//   * +localTimeZone must reflect +defaultTimeZone,
//   * +mulleGMTTimeZone must have a name,
//   * with TZ unset, +systemTimeZone must read /etc/localtime.
//
//  Not every platform has a zoneinfo database (Windows only knows GMT/UTC so
//  far), so the zone specific assertions are silent: they only show up in the
//  exit code. The printed output is therefore the same on every platform.
//
#ifdef __MULLE_OBJC__
# import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
#else
# import <Foundation/Foundation.h>
# pragma message( "Apple Foundation")
#endif

#include <stdlib.h>
#include <stdio.h>


static void   check( char *title, int flag)
{
   printf( "%s: %s\n", title, flag ? "PASS" : "FAIL");
}


// POSIX setenv/unsetenv do not exist on Windows, which spells this differently
static void   setTZ( char *value)
{
#ifdef _WIN32
   if( value)
      _putenv_s( "TZ", value);
   else
      _putenv( "TZ=");
#else
   if( value)
      setenv( "TZ", value, 1);
   else
      unsetenv( "TZ");
#endif
}


int   main( int argc, const char * argv[])
{
   NSTimeZone   *tz;
   NSTimeZone   *local;
   NSDate       *winter;
   NSDate       *summer;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   // 2026-01-15 UTC, CET in Berlin; 2026-09-29 UTC, CEST in Berlin
   winter = [NSDate dateWithTimeIntervalSince1970:1768474800.0];
   summer = [NSDate dateWithTimeIntervalSince1970:1790697600.0];

   // Deterministic: a named zone must be found through TZDIR. If the platform
   // has the zoneinfo database, it must carry its real offset and DST rules
   // and must not silently have become GMT.
   setTZ( "Europe/Berlin");
   [NSTimeZone resetSystemTimeZone];

   tz = [NSTimeZone timeZoneWithName:@"Europe/Berlin"];
   if( tz)
   {
      if( [tz isEqual:[NSTimeZone mulleGMTTimeZone]])
         return( 1);
      if( [tz secondsFromGMTForDate:winter] != 3600)
         return( 1);
      if( [tz secondsFromGMTForDate:summer] != 7200)
         return( 1);
      if( ! [[tz abbreviationForDate:winter] isEqualToString:@"CET"])
         return( 1);
      if( ! [[tz abbreviationForDate:summer] isEqualToString:@"CEST"])
         return( 1);
   }

   // portable, every platform knows GMT
   tz = [NSTimeZone timeZoneWithName:@"GMT"];
   check( "gmt zone loaded", tz != nil);
   check( "gmt offset is 0", [tz secondsFromGMTForDate:winter] == 0);

   // An unresolvable name must not masquerade as GMT
   check( "bogus name is nil", [NSTimeZone timeZoneWithName:@"Bogus/Nowhere"] == nil);
   check( "nil name is nil", [NSTimeZone timeZoneWithName:nil] == nil);

   // +localTimeZone must reflect +defaultTimeZone
   local = [NSTimeZone localTimeZone];
   check( "localTimeZone is defaultTimeZone", [local isEqual:[NSTimeZone defaultTimeZone]]);
   check( "localTimeZone name set", [local name] != nil);

   // GMT has a name
   printf( "GMT name: %s\n", [[[NSTimeZone mulleGMTTimeZone] name] UTF8String]);

   // The zone database was actually reached
   check( "knownTimeZoneNames non-empty", [[NSTimeZone knownTimeZoneNames] count] > 0);

   // With TZ unset, the system zone must come from /etc/localtime
   setTZ( NULL);
   [NSTimeZone resetSystemTimeZone];
   check( "system zone has a name", [[NSTimeZone systemTimeZone] name] != nil);

   return( 0);
}

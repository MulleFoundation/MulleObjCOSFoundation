//
//  MulleTimeZone.m
//  NSTimeZone
//
//  Created by Nat! on 19.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "import-private.h"

// other files in this library
#include "private.h"

// std-c and dependencies
#import <MulleObjCStandardFoundation/_MulleGMTTimeZone-Private.h>



@implementation NSTimeZone( Posix)

- (instancetype) initWithName:(NSString *) name
{
   extern void   *mulle_tz_context_with_name( char *, size_t *);
   size_t     size;
   void       *info;

   NSParameterAssert( [name isKindOfClass:[NSString class]]);

   [self init];

   info = mulle_tz_context_with_name( (char *) [name cString], &size);
   if( ! info)
   {
      [self release];
      return( nil);
   }

   _data = [[NSData alloc] initWithBytesNoCopy:info
                                        length:size
                                  freeWhenDone:YES];
   _name = [name copy];

   return( self);
}


+ (NSTimeZone  *) _uncachedSystemTimeZone
{
   NSString  *name;
   char      *s;

   s = getenv( "TZ");
   if( ! s)
      return( [_MulleGMTTimeZone sharedInstance]);

   name = [NSString stringWithCString:s];
   return( [NSTimeZone timeZoneWithName:name]);
}


+ (NSArray *) availableLocaleIdentifiers
{
   return( [[NSFileManager defaultManager] directoryContentsAtPath:@"/usr/share/i18n/locale"]);
}


+ (NSArray *) knownTimeZoneNames
{
   extern char   *mulle_get_timezone_zone_tab_file( void);
   NSMutableArray   *names;
   NSArray          *entries;
   NSString         *filename;
   NSString         *zonesString;
   NSString         *line;
   NSString         *name;
   NSArray          *zonesLines;
   char             *s;

   names       = [NSMutableArray array];

   s           = mulle_get_timezone_zone_tab_file();
   filename    = [NSString stringWithCString:s];
   zonesString = [NSString stringWithContentsOfFile:filename];

   zonesLines  = [zonesString componentsSeparatedByString:@"\n"];

   for( line in zonesLines)
   {
      if( [line hasPrefix:@"#"])
         continue;
      entries = [line componentsSeparatedByString:@"\t"];
      if( [entries count] < 3)
         continue;
      name = [entries objectAtIndex:2];
      [names addObject:name];
   }

   return( names);
}


+ (NSDictionary *) abbreviationDictionary
{
   static struct
   {
      char   *abr;
      char   *name;
   } lut[] =
   {
   { "ADT", "America/Halifax" },
   { "AKDT", "America/Juneau" },
   { "AKST", "America/Juneau" },
   { "ART", "America/Argentina/Buenos_Aires" },
   { "AST", "America/Halifax" },
   { "BDT", "Asia/Dhaka" },
   { "BRST", "America/Sao_Paulo" },
   { "BRT", "America/Sao_Paulo" },
   { "BST", "Europe/London" },
   { "CAT", "Africa/Harare" },
   { "CDT", "America/Chicago" },
   { "CEST", "Europe/Paris" },
   { "CET", "Europe/Paris" },
   { "CLST", "America/Santiago" },
   { "CLT", "America/Santiago" },
   { "COT", "America/Bogota" },
   { "CST", "America/Chicago" },
   { "EAT", "Africa/Addis_Ababa" },
   { "EDT", "America/New_York" },
   { "EEST", "Europe/Istanbul" },
   { "EET", "Europe/Istanbul" },
   { "EST", "America/New_York" },
   { "GMT", "GMT" },
   { "GST", "Asia/Dubai" },
   { "HKT", "Asia/Hong_Kong" },
   { "HST", "Pacific/Honolulu" },
   { "ICT", "Asia/Bangkok" },
   { "IRST", "Asia/Tehran" },
   { "IST", "Asia/Calcutta" },
   { "JST", "Asia/Tokyo" },
   { "KST", "Asia/Seoul" },
   { "MDT", "America/Denver" },
   { "MSD", "Europe/Moscow" },
   { "MSK", "Europe/Moscow" },
   { "MST", "America/Denver" },
   { "NZDT", "Pacific/Auckland" },
   { "NZST", "Pacific/Auckland" },
   { "PDT", "America/Los_Angeles" },
   { "PET", "America/Lima" },
   { "PHT", "Asia/Manila" },
   { "PKT", "Asia/Karachi" },
   { "PST", "America/Los_Angeles" },
   { "SGT", "Asia/Singapore" },
   { "UTC", "UTC" },
   { "WAT", "Africa/Lagos" },
   { "WEST", "Europe/Lisbon" },
   { "WET", "Europe/Lisbon" },
   { "WIT", "Asia/Jakarta" },
   { 0, 0 }
   };

   NSMutableDictionary   *dict;
   NSString              *key;
   NSString              *value;
   unsigned int          i;

   dict = [NSMutableDictionary dictionary];

   for( i = 0; lut[ i].abr; i++)
   {
      key   = [NSString stringWithUTF8String:lut[ i].abr];
      value = [NSString stringWithUTF8String:lut[ i].name];
      [dict setObject:value
               forKey:key];
   }
   return( dict);
}


- (NSInteger) mulleSecondsFromGMTForTimeIntervalSince1970:(NSTimeInterval) interval
{
   extern long   mulle_get_gmt_offset_for_time_interval( void *, time_t);
   long          offset;

   if( _secondsFromGMT != NSIntegerMax)
      return( _secondsFromGMT);

   if( ! _data)
      return( 0);

   offset  = mulle_get_gmt_offset_for_time_interval( [_data bytes], (time_t) interval);
   return( offset);
}


- (NSInteger) secondsFromGMTForDate:(NSDate *) aDate
{
   extern long      mulle_get_gmt_offset_for_time_interval( void *, time_t);
   NSTimeInterval   since1970;
   long             offset;

   if( _secondsFromGMT != NSIntegerMax)
      return( _secondsFromGMT);

   since1970 = [aDate timeIntervalSince1970]; // standard unix
   offset    = mulle_get_gmt_offset_for_time_interval( [_data bytes], (time_t) since1970);
   return( offset);
}


- (NSString *) abbreviationForDate:(NSDate *) aDate
{
   extern char      *mulle_get_abbreviation_for_time_interval( void *, time_t);
   NSTimeInterval   seconds;
   char             *abr;

   abr     = NULL;
#ifdef TM_ZONE
   seconds = [aDate timeIntervalSince1970]; // standard unix
   abr     = mulle_get_abbreviation_for_time_interval( [_data bytes], (time_t) seconds);
#endif
   if( ! abr || ! strlen( abr))
      return( [self name]);

   return( [NSString stringWithCString:abr]);
}


- (BOOL) isDaylightSavingTimeForDate:(NSDate *) aDate
{
   extern int       mulle_get_daylight_saving_flag_for_time_interval( void *, time_t);
   NSTimeInterval   seconds;
   int              flag;


   seconds = [aDate timeIntervalSince1970]; // standard unix
   flag    = mulle_get_daylight_saving_flag_for_time_interval( [_data bytes], (time_t) seconds);
   return( flag ? YES : NO);
}

@end

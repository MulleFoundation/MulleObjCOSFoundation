//
//  MulleObjCDateFormatter.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.05.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "import-private.h"

#import "_NSPosixDateFormatter.h"

// other files in this library
#import <MulleObjCOSBaseFoundation/private/NSDate+OSBase-Private.h>
#import "NSError+Posix.h"
#import "NSLocale+Posix.h"
#import "NSDate+Posix-Private.h"
#import "NSLocale+Posix-Private.h"

// other libraries of MulleObjCPosixFoundation
#include <MulleObjCStandardFoundation/mulle-mini-tm.h>
#include "mulle-posix-tm.h"

// std-c and dependencies
#include <time.h>
#include <ctype.h>
#include <errno.h>


@interface NSObject (Private)

- (BOOL) __isNSCalendarDate;

@end


@implementation _NSPosixDateFormatter


MULLE_OBJC_DEPENDS_ON_LIBRARY( MulleObjCStandardFoundation);


+ (void) load
{
   [NSDateFormatter mulleSetClass:self
             forFormatterBehavior:NSDateFormatterBehavior10_0];
}


- (NSDateFormatterBehavior) formatterBehavior
{
   return( NSDateFormatterBehavior10_0);
}


- (void) setDateFormat:(NSString *) format
{
   size_t   length;

   if( _cformat)
      MulleObjCInstanceDeallocateMemory( self, _cformat);

   length   = [format mulleUTF8StringLength];
   _cformat = MulleObjCInstanceAllocateNonZeroedMemory( self, length + 1);
   [format mulleGetUTF8String:_cformat
                   bufferSize:length + 1];

   // This an initial heuristic, later formatting will increase this
   // if needed
   length *= 4;
   if( length < 256)
      length = 256;

   _buflen = length;
}


#pragma mark - conversions


- (id) _dateWithFormatUTF8String:(char *) c_format
                  cStringPointer:(char **) c_str_p
{
   NSDate   *date;

   date = [self _parseDateWithUTF8String:(char **) c_str_p
                           formatUTF8String:c_format
                                  locale:[self locale]];
   return( date);
}


- (BOOL) getObjectValue:(id *) obj
              forString:(NSString *) string
                  range:(NSRange *) rangep
                  error:(NSError **) error
{
   char     *c_begin;
   char     *c_end;
   NSDate   *date;

   c_begin = [string cString];
   c_end   = c_begin;
   date    = [self _dateWithFormatUTF8String:_cformat
                           cStringPointer:&c_end];
   if( ! date)
   {
      errno = EINVAL; // whatever
      return( NO);
   }

   *obj = date;
   if( rangep)
      *rangep = NSMakeRange( 0, c_end - c_begin);
   return( YES);
}


- (NSDate *) dateFromString:(NSString *) s
{
   char     *c_str;
   NSDate   *date;

   c_str = [s cString];
   date  = [self _dateWithFormatUTF8String:_cformat
                         cStringPointer:&c_str];
   return( date);
}


//
// a NSDate is a GMT date, it should be rendered as GMT alas
// the user may specify a timeZone...
//
- (NSString *) stringFromDate:(NSDate *) date
{
   char         *buf;
   NSLocale     *locale;
   NSString     *s;
   NSTimeZone   *timeZone;
   size_t       len;

   locale = [self locale];
   if( ! locale)
      locale = [NSLocale currentLocale];
   timeZone = [self timeZone];
   if( ! timeZone && [date __isNSCalendarDate])
      timeZone = [(NSCalendarDate *) date timeZone];
   if( ! timeZone)
      timeZone = [NSTimeZone defaultTimeZone];

   // NSLog( @"Using tz %@", [timeZone abbreviation]);
   // NSLog( @"Using locale %@", [locale localeIdentifier]);

   //
   // TODO: use alloca or somesuch instead of buf ?
   //
   buf = NULL;
   for(;;)
   {
      buf = mulle_allocator_realloc( NULL, buf, _buflen);
      len = [self _printDate:date
                      buffer:buf
                      length:_buflen
               formatUTF8String:_cformat
                      locale:locale
                    timeZone:timeZone];
      if( len)
      {
          s = [NSString mulleStringWithUTF8Characters:buf
                                               length:len + 1];
          mulle_allocator_free( NULL, buf);
          return( s);
      }
      _buflen *= 2;  // weak ...
   }
}


//
// returns 0 if formatCharacter is known and was handled
// TODO: can reuse this for windows
static int   tm_sprintf_character( struct tm *tm,
                                   struct mulle_buffer *buffer,
                                   char c,
                                   NSDate *date,
                                   NSTimeZone *timeZone)
{
   NSTimeInterval   interval;
   NSInteger        hours;
   NSInteger        minutes;
   NSInteger        seconds;
   char             sign;
   int              ms;

   switch( c)
   {
   default :
      return( 1);

   case 'n' :
      mulle_buffer_add_byte( buffer, '\n');
      break;

      // https://en.wikipedia.org/wiki/ISO_8601
      // Z indicates UTC otherwise or Zulu, which is the same
   case 'z' :
      sign    = '+';
      seconds = [timeZone secondsFromGMTForDate:date];
      if( seconds == 0)
      {
         mulle_buffer_add_byte( buffer, 'Z');
         break;
      }

      if( seconds < 0)
      {
         seconds = - seconds;
         sign    = '-';
      }

      seconds  %= 24*60*60;
      minutes   = seconds / 60;
      // seconds  -= minutes * 60;
      hours     = minutes / 60;
      minutes  -= hours * 60;

      // we could put a ':' between hours and minutes but we don't have to
      mulle_buffer_sprintf( buffer, "%c%02d%02d", sign, hours, minutes);
      break;

   case 'Z' :
      // hm hm hm hm hm
      mulle_buffer_add_string( buffer, [[timeZone abbreviationForDate:date] UTF8String]);
      break;

   case 'y' :
      mulle_buffer_sprintf( buffer, "%02d", (tm->tm_year % 100));
      break;

   case 'Y' :
      mulle_buffer_sprintf( buffer, "%04d", (tm->tm_year + 1900) % 10000);
      break;

   case 'm' :
      mulle_buffer_sprintf( buffer, "%02d", (tm->tm_mon + 1) % 13);
      break;

   case 'd' :
      mulle_buffer_sprintf( buffer, "%02d", (tm->tm_mday % 32));
      break;

   case 'H' :
      mulle_buffer_sprintf( buffer, "%02d", (tm->tm_hour % 24));
      break;

   case 'M' :
      mulle_buffer_sprintf( buffer, "%02d", (tm->tm_min % 60));
      break;

   case 'S' :
      mulle_buffer_sprintf( buffer, "%02d", (tm->tm_sec % 60));
      break;

   // this used to be the fractional seconds part of the old
   // 10.0 formatter in three digits. We keep it compatible. This
   // clobbers an existing %F format in strftime.
   case 'F' :
      interval = [date timeIntervalSinceReferenceDate];

      // -2.1234 - -2.0 -> -0.1234
      interval = interval - (long) interval;

      // -0.1234 * 1000 = -123.4 -> -123
      // if we round this, the parse/reparse is more stable
      ms = (int) ((interval * 1000) + 0.5);
      if( ms < 0)
         ms += 1000;

      mulle_buffer_sprintf( buffer, "%03d", ms);
      break;
   }
   return( 0);
}


//
// We get a buffer from "above", if we need more we return 0
// _printDate:buffer:length:formatUTF8String:locale:timeZone:
//
- (size_t) _printDate:(NSDate *) date
               buffer:(char *) buf
               length:(size_t) len
        formatUTF8String:(char *) c_format
               locale:(NSLocale *) locale
             timeZone:(NSTimeZone *) timeZone
{
   auto char              tmp[ 256];
   char                   *q;
   char                   *s;
   char                   *space;
   char                   strfformat[ 4] = { '%', 0, 0, 0 };
   locale_t               xlocale;
   NSTimeInterval         interval;
   size_t                 len;
   struct mulle_buffer    buffer;
   struct tm              tm;
   NSInteger              seconds;

   NSParameterAssert( c_format);

   // setting a default timeZone here is not necessarily good and expected
   // same goes for locale
//   if( ! timeZone)
//      timeZone = [NSTimeZone defaultTimeZone];
//   if( ! locale)
//      locale = [NSLocale currentLocale];

   interval = [date timeIntervalSince1970];
   seconds  = [timeZone mulleSecondsFromGMTForTimeIntervalSince1970:interval];
   mulle_posix_tm_init_with_interval1970( &tm,
                                          interval,
                                          seconds);

   mulle_buffer_init_inflexible_with_static_bytes( &buffer, buf, len);

   xlocale = [locale xlocale];

   //
   // collect format characters until we hit %z or %Z, print easy stuff
   // ourselves, defer rest to strftime
   //
   for( s = c_format; *s; s++)
   {
      if( *s != '%')
      {
         mulle_buffer_add_byte( &buffer, *s);
         continue;
      }
      ++s;

      switch( *s)
      {
      case 'E' :
      case 'O' :
         q    = &strfformat[ 1];
         *q++ = *s++;
         break;

         //
         // handle some common "easy" and non-standard conversions locally
         //
      default :
         if( ! tm_sprintf_character( &tm, &buffer, *s, date, timeZone))
            continue;
         q = &strfformat[ 1];
      }

      *q++ = *s;
      *q++ = 0;

      //
      // can't really be larger than this or for one conversion ?
      // Does strftime corrupt ?
      space = mulle_buffer_guarantee( &buffer, 128);
      if( xlocale)
         len = strftime_l( space, 128, strfformat, &tm, xlocale);
      else
         len = strftime( space, 128, strfformat, &tm);
      mulle_buffer_advance( &buffer, len);
   }
   mulle_buffer_add_byte( &buffer, 0);

   len = mulle_buffer_has_overflown( &buffer)
            ? 0
            : mulle_buffer_get_length( &buffer) - 1; // sub 0

   mulle_buffer_done( &buffer);
   return( len);
}



- (NSDate *) _parseDateWithUTF8String:(char **) string
                     formatUTF8String:(char *) c_format
                               locale:(NSLocale *) locale
{
   //locale_t               xlocale;
   char                   *s;
   char                   *input;
   char                   *sentinel;
   char                   *q;
   char                   *remain;
   size_t                 len;
   struct mulle_buffer    buffer;
   auto char              tmp[ 256];
   char                   strpformat[ 4] = { '%', 0, 0, 0 };
   struct tm              tm;
   NSUInteger             ns;
   NSInteger              hours;
   NSInteger              minutes;
   NSInteger              seconds;
   NSTimeZone             *timeZone;
   NSString               *abbreviation;
   long                   value;
   char                   sign;
   NSUInteger             i;

   if( ! string)
      return( nil);

   NSParameterAssert( c_format);

   // setting a default timeZone here is not necessarily good and expected
   // same goes for locale
//   if( ! timeZone)
//      timeZone = [NSTimeZone defaultTimeZone];
//   if( ! locale)
//      locale = [NSLocale currentLocale];

   memset( &tm, 0, sizeof( tm));

   //xlocale  = [locale xlocale];
   timeZone = nil;
   input    = *string;
   ns       = 0;

   //
   // collect format characters until we hit %z or %Z, print easy stuff
   // ourselves, defer rest to strftime
   //
   for( s = c_format; *s; s++)
   {
      if( ! input)
      {
         errno = EACCES;
         return( nil);
      }

      if( *s != '%')
      {
         if( *input != *s)
         {
            errno = EPERM;
            return( nil);
         }
         ++input;
         continue;
      }

      ++s;

      q = &strpformat[ 1];
      switch( *s)
      {
      case 'E' :
      case 'O' :
         *q++ = *s++;
         break;

         //
         // we handle F locally
         // its 000 for ms, could be also more digits though .
         // parse 3,6,9
      case 'F' :
         for( i = 0; i < 9; i++)
         {
            if( ! isdigit( input[ i]))
               break;
            tmp[ i] = input[ i];
         }
         tmp[ i] = 0;

         ns = strtol( tmp, NULL, 10);
         switch( i)
         {
         default :
            errno = EINVAL;
            return( nil);

         case 3 :
            ns = ns * 1000 * 1000;
            break;
         case 6 :
            ns = ns * 1000;
         case 9 :
            break;
         }
         input += i;
         continue;

         // TODO: move this into a function an into NSDateFormatter
         //       so other platforms can partake
      case 'z' :
         if( ! input[ 0])
         {
            errno = EACCES;
            return( nil);
         }

         sign = input[ 0];
         if( sign == 'Z')
         {
            ++input;
            timeZone = nil;
            continue;
         }

         if( sign != '-' && sign != '+')
         {
            errno = EINVAL;
            return( nil);
         }
         ++input;

         if( ! isdigit( input[ 0]) || ! isdigit( input[ 1]))
         {
            errno = EINVAL;
            return( nil);
         }

         hours  = (input[ 0] - '0') * 10 + (input[ 1] - '0');
         input += 2;

         // minutes are optional, maybe not optional if ':' appeared ?
         minutes = 0;
         if( input[ 0] == ':')
            ++input;

         if( isdigit( input[ 0]) && isdigit( input[ 1]))
         {
            minutes = (input[ 0] - '0') * 10 + (input[ 1] - '0');
            input  += 2;
         }

         seconds  = minutes * 60;
         seconds += hours * 60 * 60;
         if( sign == '-')
            seconds = - seconds;
         timeZone = [NSTimeZone timeZoneForSecondsFromGMT:seconds];
         continue;

      case 'Z' :
         q        = tmp;
         sentinel = &tmp[ sizeof( tmp) - 1];
         while( q < sentinel)
         {
            if( ! isalpha( *s) && *s != '_' && *s != '@')
               break;
            *q++ = *s++;
         }
         input += sentinel - q;

         if( q == sentinel)
         {
            errno = EINVAL;
            return( nil);
         }

         *q++ = 0;

         abbreviation = [NSString stringWithUTF8String:tmp];
         timeZone     = [NSTimeZone timeZoneWithAbbreviation:abbreviation];
         if( ! timeZone)
         {
            errno = ENOENT;
            return( nil);
         }
         continue;
      }

      *q++ = *s;
      *q++ = 0;

//      // there is no strptime_l on linux
//      if( xlocale)
//         input = strptime_l( input, strpformat, &tm, xlocale);
//      else
      input = strptime( input, strpformat, &tm);
      if( ! input)
      {
         errno = EINVAL;
         return( nil);
      }
   }

   *string = input;

   return( [[[_dateClass alloc] _initWithTM:&tm
                                nanoseconds:ns
                                   timeZone:timeZone] autorelease]);
}



@end

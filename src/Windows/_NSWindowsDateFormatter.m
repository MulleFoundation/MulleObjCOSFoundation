#import "import-private.h"

#import "_NSWindowsDateFormatter.h"

#import <MulleObjCOSBaseFoundation/NSDate+OSBase-Private.h>
#import "NSDate+Windows-Private.h"
#import "NSTimeZone+Windows-Private.h"

#include <MulleObjCStandardFoundation/mulle-mini-tm.h>
#include "Functions/mulle-windows-tm.h"

#include <time.h>
#include <ctype.h>
#include <errno.h>


@interface NSObject (Private)

- (BOOL) __isNSCalendarDate;

@end


@implementation _NSWindowsDateFormatter


MULLE_OBJC_DEPENDS_ON_LIBRARY( MulleObjCStandardFoundation);


+ (void) load
{
   [NSDateFormatter mulleSetClass:self
             forFormatterBehavior:NSDateFormatterBehavior10_0];
}


- (instancetype) init
{
   self = [super init];
   if( self)
   {
      _dateClass = [NSCalendarDate class];
   }
   return( self);
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

   length *= 4;
   if( length < 256)
      length = 256;

   _buflen = length;
}


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
      errno = EINVAL;
      return( NO);
   }

   *obj = date;
   if( rangep)
      *rangep = NSRangeMake( 0, c_end - c_begin);
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
      _buflen *= 2;
   }
}


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
      hours     = minutes / 60;
      minutes  -= hours * 60;

      mulle_buffer_sprintf( buffer, "%c%02td%02td", sign, hours, minutes);
      break;

   case 'Z' :
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

   case 'F' :
      interval = [date timeIntervalSinceReferenceDate];
      interval = interval - (long) interval;
      ms = (int) ((interval * 1000) + 0.5);
      if( ms < 0)
         ms += 1000;

      mulle_buffer_sprintf( buffer, "%03d", ms);
      break;
   }
   return( 0);
}


- (size_t) _printDate:(NSDate *) date
               buffer:(char *) buf
               length:(size_t) len
        formatUTF8String:(char *) c_format
               locale:(NSLocale *) locale
             timeZone:(NSTimeZone *) timeZone
{
   char                   *q;
   char                   *s;
   char                   *space;
   char                   strfformat[ 4] = { '%', 0, 0, 0 };
   NSTimeInterval         interval;
   struct mulle_buffer    buffer;
   struct tm              tm;
   NSInteger              seconds;

   NSParameterAssert( c_format);

   interval = [date timeIntervalSince1970];
   seconds  = [timeZone mulleSecondsFromGMTForTimeIntervalSince1970:interval];
   mulle_windows_tm_init_with_interval1970( &tm,
                                            interval,
                                            seconds);

   mulle_buffer_init_inflexible_with_static_bytes( &buffer, buf, len);

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

      default :
         if( ! tm_sprintf_character( &tm, &buffer, *s, date, timeZone))
            continue;
         q = &strfformat[ 1];
      }

      *q++ = *s;
      *q++ = 0;

      space = mulle_buffer_guarantee( &buffer, 128);
      len = strftime( space, 128, strfformat, &tm);
      mulle_buffer_advance( &buffer, len);
   }
   mulle_buffer_add_byte( &buffer, 0);

   len = mulle_buffer_has_overflown( &buffer)
            ? 0
            : mulle_buffer_get_length( &buffer) - 1;

   mulle_buffer_done( &buffer);
   return( len);
}


- (NSDate *) _parseDateWithUTF8String:(char **) string
                     formatUTF8String:(char *) c_format
                               locale:(NSLocale *) locale
{
   char                   *s;
   char                   *input;
   auto char              tmp[ 256];
   struct tm              tm;
   NSUInteger             ns;
   NSInteger              hours;
   NSInteger              minutes;
   NSInteger              seconds;
   NSTimeZone             *timeZone;
   char                   sign;
   NSUInteger             i;
   int                    val;

   if( ! string)
      return( nil);

   NSParameterAssert( c_format);

   memset( &tm, 0, sizeof( tm));

   timeZone = nil;
   input    = *string;
   ns       = 0;

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

      switch( *s)
      {
      case 'Y' :
         if( sscanf( input, "%4d", &val) != 1)
            return( nil);
         tm.tm_year = val - 1900;
         input += 4;
         break;

      case 'y' :
         if( sscanf( input, "%2d", &val) != 1)
            return( nil);
         tm.tm_year = val;
         if( val < 70)
            tm.tm_year += 100;
         input += 2;
         break;

      case 'm' :
         if( sscanf( input, "%2d", &val) != 1)
            return( nil);
         tm.tm_mon = val - 1;
         input += 2;
         break;

      case 'd' :
         if( sscanf( input, "%2d", &val) != 1)
            return( nil);
         tm.tm_mday = val;
         input += 2;
         break;

      case 'H' :
         if( sscanf( input, "%2d", &val) != 1)
            return( nil);
         tm.tm_hour = val;
         input += 2;
         break;

      case 'M' :
         if( sscanf( input, "%2d", &val) != 1)
            return( nil);
         tm.tm_min = val;
         input += 2;
         break;

      case 'S' :
         if( sscanf( input, "%2d", &val) != 1)
            return( nil);
         tm.tm_sec = val;
         input += 2;
         break;

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
         break;

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
            timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
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
         break;

      default :
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

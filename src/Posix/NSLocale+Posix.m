/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSLocale.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "import-private.h"

#import "NSLocale+Posix.h"
#import "NSError+Posix.h"

// other files in this library
#import "NSLocale+Posix-Private.h"

// std-c and dependencies
#include <locale.h>
#include <langinfo.h>
#include <stdlib.h>


#define match( key, identifier, type, code)               \
   if( [key isEqualToString:identifier ])                 \
   {                                                      \
      return( make_mulle_locale_key_info( type, code));   \
   }


struct mulle_locale_key_info   mulle_locale_map_string_key_to_local_key( NSString *key)
{
   match( key, NSLocaleAlternateQuotationBeginDelimiterKey, -1, 0);
   match( key, NSLocaleAlternateQuotationEndDelimiterKey, -1, 0);
   match( key, NSLocaleCalendar, -1, 0);
   match( key, NSLocaleCollationIdentifier, QUERY_INFO, QUERY_COLLATION);
   match( key, NSLocaleCollatorIdentifier, -1, 0);
   match( key, NSLocaleCountryCode, -1, 0);
   match( key, NSLocaleCurrencyCode, -1, 0);
   match( key, NSLocaleCurrencySymbol, CONV_INFO, CONV_CURRENCY_SYMBOL);
   match( key, NSLocaleDecimalSeparator, CONV_INFO, CONV_DECIMAL_POINT);
   match( key, NSLocaleExemplarCharacterSet, -1, 0);
   match( key, NSLocaleGroupingSeparator, CONV_INFO, CONV_GROUPING);
   match( key, NSLocaleIdentifier, IDENTIFIER_INFO, 0);
   match( key, NSLocaleLanguageCode, QUERY_INFO, QUERY_LANGUAGE);
   match( key, NSLocaleMeasurementSystem, -1, 0);
   match( key, NSLocaleQuotationBeginDelimiterKey, -1, 0);
   match( key, NSLocaleQuotationEndDelimiterKey, -1, 0);
   match( key, NSLocaleScriptCode, -1, 0);
   match( key, NSLocaleUsesMetricSystem, -1, 0);
   match( key, NSLocaleVariantCode, QUERY_INFO, QUERY_VARIANT);

   return( make_mulle_locale_key_info( ERROR_INFO, 0));
}


id    mulle_locale_lconv_value( struct lconv *conv, int code)
{
   char   *s;
   int    nr;
   BOOL   flag;

   nr   = -1;
   s    = NULL;
   flag = NO;

   switch( code)
   {
   default                             : return( nil);
   case CONV_DECIMAL_POINT             : s = conv->decimal_point; break;
   case CONV_THOUSANDS_SEPERATOR       : s = conv->thousands_sep; break;
   case CONV_GROUPING                  : s = conv->grouping; break;
   case CONV_INT_CURRENCY_SYMBOL       : s = conv->int_curr_symbol; break;

   case CONV_CURRENCY_SYMBOL           : s = conv->currency_symbol; break;
   case CONV_MONEY_DECIMAL_POINT       : s = conv->mon_decimal_point; break;
   case CONV_MONEY_THOUSANDS_SEPERATOR : s = conv->mon_thousands_sep; break;
   case CONV_MONEY_GROUPING            : s = conv->mon_grouping; break;

   case CONV_POSITIVE_SIGN             : s = conv->positive_sign; break;
   case CONV_NEGATIVE_SIGN             : s = conv->negative_sign; break;
   case CONV_INT_FRACTIONAL_DIGITS     : nr = conv->int_frac_digits; break;
   case CONV_FRACTIONAL_DIGITS         : nr = conv->frac_digits; break;

   case CONV_POSITIVE_VALUE_CURRENCY_SYMBOL_PRECEDES               : flag = conv->p_cs_precedes; break;
   case CONV_POSITIVE_VALUE_CURRENCY_SYMBOL_SEPARATED_BY_SPACE     : flag = conv->p_sep_by_space; break;
   case CONV_NEGATIVE_VALUE_CURRENCY_SYMBOL_PRECEDES               : flag = conv->n_cs_precedes; break;
   case CONV_NEGATIVE_VALUE_CURRENCY_SYMBOL_SEPARATED_BY_SPACE     : flag = conv->n_sep_by_space; break;

   case CONV_POSITIVE_SIGN_POSITION                                : nr   = conv->p_sign_posn; break;
   case CONV_NEGATIVE_SIGN_POSITION                                : nr   = conv->n_sign_posn; break;
   case CONV_INT_POSITIVE_VALUE_CURRENCY_SYMBOL_PRECEDES           : flag = conv->int_p_cs_precedes; break;
   case CONV_INT_NEGATIVE_VALUE_CURRENCY_SYMBOL_PRECEDES           : flag = conv->int_n_cs_precedes; break;

   case CONV_INT_POSITIVE_VALUE_CURRENCY_SYMBOL_SEPARATED_BY_SPACE : flag = conv->int_p_sep_by_space; break;
   case CONV_INT_NEGATIVE_VALUE_CURRENCY_SYMBOL_SEPARATED_BY_SPACE : flag = conv->int_n_sep_by_space; break;
   case CONV_INT_POSITIVE_SIGN_POSITION                            : flag = conv->int_p_sign_posn; break;
   case CONV_INT_NEGATIVE_SIGN_POSITION                            : flag = conv->int_n_sign_posn; break;
   }

   if( s)
      return( [NSString stringWithCString:s]);

   if( nr != -1)
      return( [NSNumber numberWithInt:nr]);

   return( [NSNumber numberWithBool:flag]);
}


@implementation NSLocale( Posix)

static NSArray   *identifiers;

+ (void) unload
{
   if( identifiers) // avoid +initialize due to -release (noticed in trace)
   {
      [identifiers release];
      identifiers = nil;
   }
}

// So on linux the locale available from <locale.h> is basically the contents
// of a compiled file /usr/lib/locale/locale-archive. There is no API to list
// it's contents though it seems.
// This file is generated from /usr/share/i18n and there there is an
// index file SUPPORTED which lists all. It's not clear, even dubious,
// that all SUPPORTED locales have been compiled.
//
// The content is /usr/share/locale are just localized LC_MESSAGES for unix
// tools it seems. Nothing we need. As long as we aren't running in a
// containerized thingy, where we can execute "locale -a". This is the easiest
// thing.
//
// https://www.man7.org/linux/man-pages/man1/localedef.1.html
//
+ (NSArray *) availableLocaleIdentifiers
{
   NSString   *command;
   NSString   *tmpFile;
   NSString   *name;
   NSString   *s;

   if( identifiers)
      return( identifiers);

   tmpFile     = NSTemporaryDirectory();
   name        = [[NSProcessInfo processInfo] globallyUniqueString];
   tmpFile     = [tmpFile stringByAppendingPathComponent:name];
   tmpFile     = [tmpFile stringByAppendingPathExtension:@"txt"];
   command     = [NSString stringWithFormat:@"/usr/bin/locale -e > \"%@\"", tmpFile];
   if( ! system( [command cString]))
   {
      s           = [NSString stringWithContentsOfFile:tmpFile];
      identifiers = [s componentsSeparatedByString:@"\n"];
   }
   [[NSFileManager defaultManager] _removeFileAtPath:tmpFile];

   if( ! [identifiers count])
      identifiers  = @[ @"C", @"POSIX", @"en_US.utf8" ];

   identifiers = [identifiers copy];
   return( identifiers);
}


/*
Try to load a dictionary named:

de_DE.plist
{
    NSAMPMDesignation = ("vorm.", "nachm.");
    NSDateFormatString = "%A, %e. %B %Y";
    NSDateTimeOrdering = DMYH;
    NSEarlierTimeDesignations = ("fr\U00fcher", vorher, letzten );
    NSHourNameDesignations = (
        (0, mitternachts, Mitternacht),
        (8, morgens, Morgen),
        (12, mittags, Mittag),
        (15, nachmittags, Nachmittag),
        (18, abends, Abend)
    );
    NSLaterTimeDesignations = ("n\U00e4chsten");
    NSMonthNameArray = (
        Januar,
        Februar,
        "M\U00e4rz",
        April,
        Mai,
        Juni,
        Juli,
        August,
        September,
        Oktober,
        November,
        Dezember
    );
    NSNextDayDesignations = (morgen);
    NSNextNextDayDesignations = ( "\U00fcbermorgen");
    NSPriorDayDesignations = ( gestern);
    NSShortDateFormatString = "%d.%m.%y";
    NSShortMonthNameArray = (Jan, Feb, Mrz, Apr, Mai, Jun, Jul, Aug, Sep, Okt, Nov, Dez);
    NSShortTimeDateFormatString = "%d.%m.%y %H:%M";
    NSShortWeekDayNameArray = (So, Mo, Di, Mi, Do, Fr, Sa);
    NSThisDayDesignations = ( heute, jetzt);
    NSTimeDateFormatString = "%A, %e. %B %Y %1H:%M Uhr %Z";
    NSTimeFormatString = "%H:%M:%S";
    NSWeekDayNameArray = (Sonntag, Montag, Dienstag, Mittwoch, Donnerstag, Freitag, Samstag);
    NSYearMonthWeekDesignations = ( Jahr, Monat, Woche);
}
*/

+ (NSString *) auxiliaryLocalePath
{
   return( @"/usr/share/mulle-locale");
}


+ (NSDictionary *) auxiliaryLocaleInfoForIdentifier:(NSString *) identifier
{
   NSString  *path;

   path = [[self auxiliaryLocalePath] stringByAppendingPathComponent:identifier];
   path = [path stringByAppendingPathExtension:@"plist"];
   return( [NSDictionary dictionaryWithContentsOfFile:path]);
}


- (instancetype) initWithLocaleIdentifier:(NSString *) name
{
   locale_t       xlocale;
   NSDictionary   *auxInfo;

   MulleObjCSetPosixErrorDomain();

   xlocale = newlocale( LC_ALL_MASK, [name cString], NULL);

   if( ! xlocale || ! name)
   {
      [self release];
      return( nil);
   }

   _xlocale    = xlocale;
   _identifier = [name copy];
   _keyValues  = [NSMutableDictionary new];

   auxInfo = [[self class] auxiliaryLocaleInfoForIdentifier:name];
   [_keyValues addEntriesFromDictionary:auxInfo];

   return( self);
}


- (void) dealloc
{
   [_identifier release];
   [_keyValues release];
   if( _xlocale)
      freelocale( _xlocale);

   [super dealloc];
}


- (id) objectForKey:(id) key
{
   id               value;

   value = [_keyValues objectForKey:key];
   if( value)
   {
      if( value == [NSNull null])
         value = nil;
      return( value);
   }

   value = [self _localeInfoForKey:key];
   [_keyValues setObject:value ? value : [NSNull null]
                  forKey:key];
   return( value);
}


- (locale_t) xlocale
{
   return( _xlocale);
}

@end


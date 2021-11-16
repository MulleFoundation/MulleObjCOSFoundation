//
//  NSDate+Darwin.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#define _GNU_SOURCE

#import "import-private.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation
#import <MulleObjCPosixFoundation/private/NSLocale+Posix-Private.h>

// std-c and dependencies
#include <time.h>
#include <locale.h>


@implementation NSDateFormatter (Linux)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCPosixFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}



- (size_t) _printTM:(struct tm *) tm
             buffer:(char *) buf
             length:(size_t) len
      formatUTF8String:(char *) c_format
             locale:(NSLocale *) locale
{
   locale_t   old_locale;
   locale_t   new_locale;

   NSParameterAssert( tm);
   NSParameterAssert( c_format);
   NSParameterAssert( ! locale || [locale isKindOfClass:[NSLocale class]]);

   // locale_t is 0, the locale is left unchanged, which is nice if
   // locale is nil
   old_locale = uselocale( [locale xlocale]);
   {
      len = strftime( buf, len, c_format, tm);
   }
   uselocale( old_locale);

   return( len);
}

@end

//
//  NSDate+Darwin.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "import-private.h"

// other files in this library
#include "mulle-bsd-tm.h"

// other libraries of MulleObjCPosixFoundation
#import <MulleObjCOSBaseFoundation/NSDate+OSBase-Private.h>
#import <MulleObjCPosixFoundation/NSLocale+Posix-Private.h>
#include <MulleObjCStandardFoundation/mulle-mini-tm.h>
#include <MulleObjCPosixFoundation/mulle-posix-tm.h>

// std-c and dependencies
#include <time.h>
#include <xlocale.h>


@implementation NSDateFormatter( BSD)

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
   locale_t    xlocale;

   NSParameterAssert( tm);
   NSParameterAssert( c_format);
   NSParameterAssert( [locale isKindOfClass:[NSLocale class]]);

   xlocale  = [locale xlocale];
   if( xlocale)
      len = strftime_l( buf, len, c_format, tm, xlocale);
   else
      len = strftime( buf, len, c_format, tm);
   return( len);
}

@end

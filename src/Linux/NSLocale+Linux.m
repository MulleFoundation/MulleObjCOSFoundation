//
//  NSLocale+Linux.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#define _GNU_SOURCE

#import "import-private.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation
#import <MulleObjCPosixFoundation/NSLocale+Posix-Private.h>

// std-c and dependencies
#include <locale.h>
#include <langinfo.h>


@implementation NSLocale (Linux)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCPosixFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}

+ (NSString *) systemLocalePath
{
   // how can we get this reliably ?
   return( @"/usr/share/i18n/locales");
}


+ (instancetype) _systemLocale
{
   // bullshit
   return( [[[NSLocale alloc] initWithLocaleIdentifier:@"C"] autorelease]);
}


+ (instancetype) _currentLocale
{
   // bullshit
   return( [[[NSLocale alloc] initWithLocaleIdentifier:@"C"] autorelease]);
}


- (id) _localeInfoForKey:(id) key
{
   struct mulle_locale_key_info   info;
   char                           *s;

   s    = NULL;
   info = mulle_locale_map_string_key_to_local_key( key);

   switch( info.type)
   {
   case IDENTIFIER_INFO :
      return( _identifier);

   case LANG_INFO  :
      s = nl_langinfo_l( info.code, _xlocale);
      return( s ? [NSString stringWithCString:s] : nil);
   }
   return( nil);
}

@end

/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSLocale+Windows.m is a part of MulleObjCOSFoundation
 *
 *  Copyright (C) 2024 Mulle kybernetiK.
 *  All rights reserved.
 *
 */

#import "import-private.h"

// Windows headers
#include <windows.h>


@implementation NSLocale( Windows)


+ (instancetype) _systemLocale
{
   return( [[[NSLocale alloc] initWithLocaleIdentifier:@"C"] autorelease]);
}


+ (instancetype) _currentLocale
{
   WCHAR      localeName[ LOCALE_NAME_MAX_LENGTH];
   
   if( GetUserDefaultLocaleName( localeName, LOCALE_NAME_MAX_LENGTH))
   {
      NSString   *identifier;
      
      identifier = [[[NSString alloc] mulleInitWithUTF16Characters:(mulle_utf16_t *) localeName
                                                            length:wcslen( localeName)] autorelease];
      return( [[[NSLocale alloc] initWithLocaleIdentifier:identifier] autorelease]);
   }
   
   return( [[[NSLocale alloc] initWithLocaleIdentifier:@"C"] autorelease]);
}


- (instancetype) initWithLocaleIdentifier:(NSString *) name
{
   if( ! name)
   {
      [self release];
      return( nil);
   }

   _identifier = [name copy];
   _keyValues  = [NSMutableDictionary new];

   return( self);
}


- (void) dealloc
{
   [_identifier release];
   [_keyValues release];

   [super dealloc];
}

@end

/*
 *  MulleFoundation - A tiny Foundation replacement
 *
 *  NSCalendarDate+Localization.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "import.h"


@interface NSCalendarDate( _Localization)

- (id) initWithString:(NSString *) description
       calendarFormat:(NSString *) format
               locale:(NSLocale *) locale;
- (NSString *) descriptionWithCalendarFormat:(NSString *) format
                                      locale:(NSLocale *) locale;
- (NSString *) descriptionWithLocale:(NSLocale *) locale;

@end

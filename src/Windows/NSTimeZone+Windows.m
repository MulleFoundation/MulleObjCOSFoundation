//
//  NSTimeZone+Windows.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 06.02.26
//  Copyright © 2026 Mulle kybernetiK. All rights reserved.
//

#import "import-private.h"

// std-c and dependencies
#include <windows.h>
#include <time.h>

// other files in this library
#import <MulleObjCStandardFoundation/_MulleGMTTimeZone-Private.h>


@implementation NSTimeZone( Windows)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCDeps), @selector( MulleObjCOSWindowsFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}


- (instancetype) initWithName:(NSString *) name
{
   NSParameterAssert( [name isKindOfClass:[NSString class]]);

   [self init];

   // For now, only support GMT/UTC on Windows
   if( ! [name isEqualToString:@"GMT"] && ! [name isEqualToString:@"UTC"])
   {
      [self release];
      return( nil);
   }

   _name = [name copy];
   _secondsFromGMT = 0;

   return( self);
}


+ (NSTimeZone *) _uncachedSystemTimeZone
{
   // For consistency with Posix behavior, return GMT as default
   // Windows applications should explicitly set timezone if needed
   return( [_MulleGMTTimeZone sharedInstance]);
}


+ (NSArray *) knownTimeZoneNames
{
   // Return minimal set for Windows
   return( @[ @"GMT", @"UTC" ]);
}


+ (NSDictionary *) abbreviationDictionary
{
   return( @{
      @"GMT": @"GMT",
      @"UTC": @"UTC"
   });
}


- (NSInteger) mulleSecondsFromGMTForTimeIntervalSince1970:(NSTimeInterval) interval
{
   if( _secondsFromGMT != NSIntegerMax)
      return( _secondsFromGMT);

   return( 0);
}


- (NSInteger) secondsFromGMTForDate:(NSDate *) aDate
{
   if( _secondsFromGMT != NSIntegerMax)
      return( _secondsFromGMT);

   return( 0);
}


- (NSString *) abbreviationForDate:(NSDate *) aDate
{
   return( [self name]);
}


- (BOOL) isDaylightSavingTimeForDate:(NSDate *) aDate
{
   return( NO);
}

@end


@implementation _MulleGMTTimeZone( Windows)

- (NSInteger) mulleSecondsFromGMTForTimeIntervalSince1970:(NSTimeInterval) interval
{
   return( 0);
}

@end

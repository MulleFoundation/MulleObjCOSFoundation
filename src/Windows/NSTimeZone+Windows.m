//
//  NSTimeZone+Windows.m
//  MulleObjCOSFoundation
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
#import "import-private.h"

// std-c and dependencies
#include <windows.h>
#include <time.h>

// other files in this library
#import <MulleObjCStandardFoundation/_MulleGMTTimeZone-Private.h>


@implementation NSTimeZone( Windows)


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
   MULLE_C_UNUSED( interval);
   if( _secondsFromGMT != NSIntegerMax)
      return( _secondsFromGMT);

   return( 0);
}


- (NSInteger) secondsFromGMTForDate:(NSDate *) aDate
{
   MULLE_C_UNUSED( aDate);
   if( _secondsFromGMT != NSIntegerMax)
      return( _secondsFromGMT);

   return( 0);
}


- (NSString *) abbreviationForDate:(NSDate *) aDate
{
   MULLE_C_UNUSED( aDate);
   return( [self name]);
}


- (BOOL) isDaylightSavingTimeForDate:(NSDate *) aDate
{
   MULLE_C_UNUSED( aDate);
   return( NO);
}

@end


@implementation _MulleGMTTimeZone( Windows)

- (NSInteger) mulleSecondsFromGMTForTimeIntervalSince1970:(NSTimeInterval) interval
{
   MULLE_C_UNUSED( interval);
   return( 0);
}

@end

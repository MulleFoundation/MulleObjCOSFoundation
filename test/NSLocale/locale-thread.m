//
//  locale-thread.m
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
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


@interface NSLocaleThreadTester : NSObject
@end


@implementation NSLocaleThreadTester

// Runs on a secondary thread. The locale singleton and its lock-protected
// _keyValues cache were created on the main thread, so this aborted in the
// runtime before reaching the thread-safe method bodies.
+ (void) test:(id) locale
{
   [locale languageCode];
   [locale languageCode];

   mulle_printf( "worker-locale=%s\n", [locale localeIdentifier] ? "ok" : "nil");
}

@end


int   main( int argc, char *argv[])
{
#if defined( __MULLE_OBJC__)
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      NSLocale   *locale;
      NSThread   *thread;

      // create the locale singleton and warm its cache on the main thread
      locale = [NSLocale currentLocale];
      [locale languageCode];
      [locale languageCode];

      mulle_printf( "main-locale=%s\n", [locale localeIdentifier] ? "ok" : "nil");

      thread = [[[NSThread alloc] initWithTarget:[NSLocaleThreadTester class]
                                        selector:@selector( test:)
                                          object:locale] autorelease];
      [thread mulleStart];
      [thread mulleJoin];
   }

   return( 0);
}

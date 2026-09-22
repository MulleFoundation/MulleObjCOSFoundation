//
//  bundle-thread.m
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


@interface NSBundleThreadTester : NSObject
@end


@implementation NSBundleThreadTester

// Runs on a secondary thread. The class-level bundle registry took TAO
// affinity to the thread that touched NSBundle first (here the main thread),
// so this aborted in the runtime before reaching the lock-protected method
// bodies of get_or_register_bundle.
+ (void) test:(id) unused
{
   MULLE_C_UNUSED( unused);

   mulle_printf( "worker-nil=%d\n",
                 [NSBundle bundleWithPath:@"/tmp/mulle-objc-does-not-exist"] == nil);

   // exercises the lock-protected _localizedStringTables cache (and the
   // NSLocale / NSUserDefaults singletons it reaches)
   [[NSBundle mainBundle] localizedStringForKey:@"NoSuchKey"
                                          value:nil
                                          table:@"NoSuchTable"];
   mulle_printf( "worker-localized=1\n");
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
      NSBundle   *bundle;
      NSThread   *thread;

      // first touch on the main thread creates the class-level registry here
      mulle_printf( "main-nil=%d\n",
                    [NSBundle bundleWithPath:@"/tmp/mulle-objc-does-not-exist"] == nil);

      // also create the localization table of the main bundle here
      bundle = [NSBundle mainBundle];
      [bundle localizedStringForKey:@"NoSuchKey"
                              value:nil
                              table:@"NoSuchTable"];
      mulle_printf( "main-localized=1\n");

      thread = [[[NSThread alloc] initWithTarget:[NSBundleThreadTester class]
                                        selector:@selector( test:)
                                          object:nil] autorelease];
      [thread mulleStart];
      [thread mulleJoin];
   }

   return( 0);
}

#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


@interface NSUserDefaultsThreadTester : NSObject
@end


@implementation NSUserDefaultsThreadTester

// Runs on a secondary thread. The standardUserDefaults singleton and its
// lock-protected domains were created on the main thread, so this aborted
// in the runtime before reaching the thread-safe method bodies.
+ (void) test:(id) defaults
{
   [defaults setObject:@"worker"
                forKey:@"mulle.test.thread"];
   mulle_printf( "worker=%s\n", [[defaults stringForKey:@"mulle.test.thread"] UTF8String]);
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
      NSUserDefaults   *defaults;
      NSThread         *thread;

      // create the singleton on the main thread first
      defaults = [NSUserDefaults standardUserDefaults];
      [defaults setObject:@"main"
                   forKey:@"mulle.test.thread"];
      mulle_printf( "main=%s\n", [[defaults stringForKey:@"mulle.test.thread"] UTF8String]);

      thread = [[[NSThread alloc] initWithTarget:[NSUserDefaultsThreadTester class]
                                        selector:@selector( test:)
                                          object:defaults] autorelease];
      [thread mulleStart];
      [thread mulleJoin];

      mulle_printf( "final=%s\n", [[defaults stringForKey:@"mulle.test.thread"] UTF8String]);
   }

   return( 0);
}

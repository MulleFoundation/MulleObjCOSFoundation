#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


@interface NSProcessInfoThreadTester : NSObject
@end


@implementation NSProcessInfoThreadTester

// Runs on a secondary thread. NSProcessInfo is declared thread-safe, but its
// lazy ivars were initialized without a lock and globallyUniqueString used a
// non-atomic counter.
+ (void) test:(id) info
{
   mulle_printf( "worker-arguments=%d\n", [[info arguments] count] > 0);
   mulle_printf( "worker-environment=%d\n", [[info environment] count] > 0);
   mulle_printf( "worker-executable=%d\n", [[info _executablePath] length] > 0);
   mulle_printf( "worker-unique=%d\n", [[info globallyUniqueString] length] > 0);
}

@end


int   main( int argc, const char * argv[])
{
#if defined( __MULLE_OBJC__)
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      NSProcessInfo   *info;
      NSThread        *thread;

      // materialize the lazy ivars on the main thread first
      info = [NSProcessInfo processInfo];
      mulle_printf( "main-arguments=%d\n", [[info arguments] count] > 0);
      mulle_printf( "main-environment=%d\n", [[info environment] count] > 0);
      mulle_printf( "main-executable=%d\n", [[info _executablePath] length] > 0);

      thread = [[[NSThread alloc] initWithTarget:[NSProcessInfoThreadTester class]
                                        selector:@selector( test:)
                                          object:info] autorelease];
      [thread mulleStart];
      [thread mulleJoin];
   }

   return( 0);
}

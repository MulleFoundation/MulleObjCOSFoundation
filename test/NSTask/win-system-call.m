//
//  win-system-call.m
//  Test mulleDataSystemCallWithArguments
//

#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int main(int argc, const char * argv[])
{
#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      NSDictionary   *result;
      NSData         *output;

      mulle_fprintf( stderr, "Calling mulleDataSystemCallWithArguments...\n");
      
      result = [NSTask mulleDataSystemCallWithArguments:@[ @"cmd.exe", @"/c", @"echo", @"SYSTEM" ]
                                        workingDirectory:nil
                                       standardInputData:nil
                                                 options:NSTaskSystemReceiveStandardOutput];

      mulle_fprintf( stderr, "Call returned\n");

      if( [result objectForKey:NSTaskExceptionKey])
      {
         mulle_fprintf( stderr, "Exception: %@\n", [result objectForKey:NSTaskExceptionKey]);
         return( 1);
      }

      output = [result objectForKey:NSTaskStandardOutputDataKey];
      mulle_fprintf( stderr, "Output length: %ld\n", (long)[output length]);

      if( [output length])
         mulle_printf( "%.*s", (int)[output length], (char *)[output bytes]);
      else
         mulle_printf( "NO OUTPUT\n");
   }

   return 0;
}

//
//  win-nstask-simple.m
//  Test NSTask with simple command
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
      NSTask        *task;
      NSPipe        *pipe;
      NSFileHandle  *file;
      NSData        *data;

      task = [[NSTask new] autorelease];
      pipe = [NSPipe pipe];

      [task setLaunchPath:@"cmd.exe"];
      [task setArguments:@[ @"/c", @"echo", @"PASS" ]];
      [task setStandardOutput:pipe];

      mulle_fprintf( stderr, "Launching task...\n");
      [task launch];
      mulle_fprintf( stderr, "Task launched\n");

      file = [pipe fileHandleForReading];
      mulle_fprintf( stderr, "Reading data...\n");
      data = [file readDataToEndOfFile];
      mulle_fprintf( stderr, "Read %ld bytes\n", (long)[data length]);

      [task waitUntilExit];
      mulle_fprintf( stderr, "Task exited with status %d\n", [task terminationStatus]);

      if( [data length])
         mulle_printf( "%.*s", (int)[data length], (char *)[data bytes]);
      else
         mulle_printf( "NO OUTPUT\n");
   }

   return 0;
}

//
//  win-thread-pipe.m
//  Test threading with pipes on Windows
//

#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

static int readThread( NSThread *thread, void *info)
{
   NSFileHandle   *handle = info;
   NSData         *data;
   
   mulle_fprintf( stderr, "Read thread started\n");
   [handle mulleGainAccess];
   
   data = [handle readDataToEndOfFile];
   mulle_fprintf( stderr, "Read thread got %ld bytes\n", (long)[data length]);
   
   if( [data length])
      mulle_printf( "%.*s", (int)[data length], (char *)[data bytes]);
   
   [handle autorelease];
   return( 0);
}

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
      NSFileHandle  *readHandle;
      NSThread      *thread;

      task = [[NSTask new] autorelease];
      pipe = [NSPipe pipe];

      [task setLaunchPath:@"cmd.exe"];
      [task setArguments:@[ @"/c", @"echo", @"THREADED" ]];
      [task setStandardOutput:pipe];

      mulle_fprintf( stderr, "Launching task...\n");
      [task launch];
      mulle_fprintf( stderr, "Task launched\n");

      // Close write end in parent
      [[pipe fileHandleForWriting] closeFile];

      // Start thread to read
      readHandle = [[pipe fileHandleForReading] retain];
      [readHandle mulleRelinquishAccess];
      thread = [[[NSThread alloc] mulleInitWithFunction:readThread
                                               argument:readHandle] autorelease];
      [thread mulleStart];
      mulle_fprintf( stderr, "Thread started\n");

      [task waitUntilExit];
      mulle_fprintf( stderr, "Task exited with status %d\n", [task terminationStatus]);

      [thread mulleJoin];
      mulle_fprintf( stderr, "Thread joined\n");
   }

   return 0;
}

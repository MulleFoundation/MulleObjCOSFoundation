#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static NSDate   *inSeconds( NSTimeInterval interval)
{
   return( [NSDate dateWithTimeIntervalSinceReferenceDate:
              [NSDate timeIntervalSinceReferenceDate] + interval]);
}


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


@interface Watcher : NSObject
{
   NSData   *_data;
   BOOL     _notified;
}

- (BOOL) notified;
- (NSData *) data;

@end


@implementation Watcher

- (void) dealloc
{
   [_data release];
   [super dealloc];
}


- (BOOL) notified
{
   return( _notified);
}


- (NSData *) data
{
   return( _data);
}


- (void) got:(NSNotification *) notification
{
   _data     = [[[notification userInfo] objectForKey:NSFileHandleNotificationDataItem] retain];
   _notified = YES;
}

@end


int   main( int argc, char *argv[])
{
   NSRunLoop      *runLoop;
   NSPipe         *pipe;
   NSFileHandle   *reader;
   NSFileHandle   *writer;
   Watcher        *watcher;
   NSData         *expected;
   NSInteger      i;

   runLoop  = [NSRunLoop currentRunLoop];
   pipe     = [NSPipe pipe];
   reader   = [pipe fileHandleForReading];
   writer   = [pipe fileHandleForWriting];
   watcher  = [[Watcher new] autorelease];
   expected = [NSData dataWithBytes:"HELLO" length:5];

   [[NSNotificationCenter defaultCenter] addObserver:watcher
                                            selector:@selector( got:)
                                                name:NSFileHandleReadCompletionNotification
                                              object:reader];

   [reader readInBackgroundAndNotify];
   [writer writeData:expected];
   [writer closeFile];

   for( i = 0; i < 20 && ! [watcher notified]; i++)
      [runLoop runMode:NSDefaultRunLoopMode
            beforeDate:inSeconds( 0.1)];

   show( @"notified", [watcher notified]);
   show( @"data", [[watcher data] isEqualToData:expected]);

   [[NSNotificationCenter defaultCenter] removeObserver:watcher];

   return( 0);
}

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


@interface Target : NSObject
{
   int   _fired;
   id    _last;
}

- (int) fired;
- (id) last;

@end


@implementation Target

- (int) fired
{
   return( _fired);
}


- (id) last
{
   return( _last);
}


- (void) mark:(id) argument
{
   _fired++;
   _last = argument;
}

@end


int   main( int argc, char *argv[])
{
   NSRunLoop   *runLoop;
   Target      *target;

   runLoop = [NSRunLoop currentRunLoop];
   target  = [[Target new] autorelease];

   [target performSelector:@selector( mark:)
                withObject:@"A"
                afterDelay:0.0];
   [runLoop runUntilDate:inSeconds( 0.1)];
   show( @"perform-fired", [target fired] == 1 && [[target last] isEqualToString:@"A"]);

   [target performSelector:@selector( mark:)
                withObject:@"B"
                afterDelay:0.0];
   [NSObject cancelPreviousPerformRequestsWithTarget:target
                                            selector:@selector( mark:)
                                              object:@"B"];
   [runLoop runUntilDate:inSeconds( 0.05)];
   show( @"cancel-object", [target fired] == 1);

   [target performSelector:@selector( mark:)
                withObject:@"C"
                afterDelay:0.0];
   [NSObject cancelPreviousPerformRequestsWithTarget:target];
   [runLoop runUntilDate:inSeconds( 0.05)];
   show( @"cancel-target", [target fired] == 1);

   [target performSelector:@selector( mark:)
                withObject:@"D"
                afterDelay:0.0
                   inModes:@[ NSDefaultRunLoopMode ]];
   [runLoop runUntilDate:inSeconds( 0.1)];
   show( @"perform-modes-fired", [target fired] == 2 && [[target last] isEqualToString:@"D"]);

   return( 0);
}

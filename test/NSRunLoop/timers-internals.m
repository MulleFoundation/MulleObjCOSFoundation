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
   int   _timerFired;
}

- (int) fired;
- (int) timerFired;

@end


@implementation Target

- (int) fired
{
   return( _fired);
}


- (int) timerFired
{
   return( _timerFired);
}


- (void) mark:(id) argument
{
   MULLE_C_UNUSED( argument);
   _fired++;
}


- (void) markTimer:(NSTimer *) timer
{
   MULLE_C_UNUSED( timer);
   _timerFired++;
}

@end


int   main( int argc, char *argv[])
{
   NSRunLoop   *runLoop;
   Target      *target;
   NSTimer     *timer;
   BOOL        rval;

   runLoop = [NSRunLoop currentRunLoop];
   target  = [[Target new] autorelease];

   // runMode fires a due timer
   timer = [NSTimer timerWithTimeInterval:0.0
                                   target:target
                                 selector:@selector( markTimer:)
                                 userInfo:nil
                                  repeats:NO];
   [runLoop addTimer:timer
             forMode:NSDefaultRunLoopMode];
   rval = [runLoop runMode:NSDefaultRunLoopMode
                beforeDate:inSeconds( 1.0)];
   show( @"runmode-yes", rval == YES);
   show( @"timer-fired", [target timerFired] == 1);

   // acceptInputForMode fires a due timer
   timer = [NSTimer timerWithTimeInterval:0.0
                                   target:target
                                 selector:@selector( markTimer:)
                                 userInfo:nil
                                  repeats:NO];
   [runLoop addTimer:timer
             forMode:NSDefaultRunLoopMode];
   [runLoop acceptInputForMode:NSDefaultRunLoopMode
                    beforeDate:inSeconds( 1.0)];
   show( @"acceptinput-fired", [target timerFired] == 2);

   // an invalidated timer does not fire
   timer = [NSTimer timerWithTimeInterval:0.0
                                   target:target
                                 selector:@selector( markTimer:)
                                 userInfo:nil
                                  repeats:NO];
   [runLoop addTimer:timer
             forMode:NSDefaultRunLoopMode];
   [timer invalidate];
   [runLoop runMode:NSDefaultRunLoopMode
         beforeDate:inSeconds( 0.1)];
   show( @"invalidate-no-fire", [target timerFired] == 2);

   // regression: performSelector on a mode that already fired a timer
   [runLoop performSelector:@selector( mark:)
                     target:target
                   argument:nil
                      order:1
                      modes:@[ NSDefaultRunLoopMode ]];
   rval = [runLoop runMode:NSDefaultRunLoopMode
                beforeDate:inSeconds( 1.0)];
   show( @"perform-after-timer", rval == YES && [target fired] == 1);

   return( 0);
}

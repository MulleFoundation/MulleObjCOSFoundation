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
}

- (int) fired;

@end


@implementation Target

- (int) fired
{
   return( _fired);
}


- (void) mark:(id) argument
{
   MULLE_C_UNUSED( argument);
   _fired++;
}

@end


int   main( int argc, char *argv[])
{
   NSRunLoop   *runLoop;
   Target      *target;
   NSTimer     *timer;
   NSDate      *date;
   BOOL        rval;

   runLoop = [NSRunLoop currentRunLoop];
   target  = [[Target new] autorelease];

   show( @"current-non-nil", runLoop != nil);
   show( @"main-non-nil", [NSRunLoop mainRunLoop] != nil);
   show( @"main-is-current", [NSRunLoop mainRunLoop] == runLoop);
   show( @"mulle-current-is-current", [NSRunLoop mulleCurrentRunLoop] == runLoop);
   show( @"mode-initially-nil", [runLoop currentMode] == nil);

   // an idle mode does not run
   rval = [runLoop runMode:@"NoMode"
                beforeDate:inSeconds( 0.0)];
   show( @"idle-runmode-no", rval == NO);

   // limitDateForMode reports the next timer, without running
   timer = [NSTimer timerWithTimeInterval:0.05
                                   target:target
                                 selector:@selector( mark:)
                                 userInfo:nil
                                  repeats:NO];
   [runLoop addTimer:timer
             forMode:NSDefaultRunLoopMode];

   date = [runLoop limitDateForMode:NSDefaultRunLoopMode];
   show( @"limit-date", date != nil && [date isEqual:[timer fireDate]]);
   [timer invalidate];

   // performSelector is delivered by runMode
   [runLoop performSelector:@selector( mark:)
                     target:target
                   argument:@1
                      order:1
                      modes:@[ @"PerformMode" ]];
   rval = [runLoop runMode:@"PerformMode"
                beforeDate:inSeconds( 1.0)];
   show( @"perform-fired", [target fired] == 1);

   // cancellation removes pending messages
   [runLoop performSelector:@selector( mark:)
                     target:target
                   argument:@2
                      order:1
                      modes:@[ @"PerformMode" ]];
   [runLoop cancelPerformSelectorsWithTarget:target];
   [runLoop runMode:@"PerformMode"
         beforeDate:inSeconds( 0.1)];
   show( @"cancel-no-fire", [target fired] == 1);

   show( @"mode-finally-nil", [runLoop currentMode] == nil);

   return( 0);
}

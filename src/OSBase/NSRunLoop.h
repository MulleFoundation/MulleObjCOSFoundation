//
//  NSRunLoop.h
//  MulleObjCOSFoundation
//
//  Created by Nat! on 20.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#import "import.h"


@class NSTimer;


// these are used internally, not for public consumption
struct MulleRunLoopMessage
{
   NSUInteger   order;
   NSUInteger   generation;   // only used to keep sorting somewhat stable (could use mergesort though)
   id           target;
   id           argument;
   SEL          selector;
};


struct MulleRunLoopMessageArray
{
   NSUInteger                   n;
   NSUInteger                   size;
   struct mulle_allocator       *allocator;
   struct MulleRunLoopMessage   *items;
};



typedef NSString   *NSRunLoopMode;


struct MulleRunLoopMode
{
   struct MulleRunLoopMessageArray   messages;
   NSMutableArray                    *timers;
   NSString                          *name;
   mulle_atomic_pointer_t            nInputsTimersMessages;
   void                              *osspecific;
   SEL                               osspecificFinalize;
};


MULLE_OBJC_OSBASE_FOUNDATION_GLOBAL
NSString   *NSDefaultRunLoopMode;

//
// basically a wrapper around select(2) in POSIX
//
// this object is supposed to exist per thread, and should not be shared
// with other threads
//
@interface NSRunLoop : NSObject
{
   NSMapTable             *_modeTable;
   NSMapTable             *_fileHandleTable;  // todo: move to mode
   NSMutableArray         *_readyHandles;
   NSRunLoopMode          _currentModeName;
   mulle_thread_mutex_t   _lock;
}

+ (NSRunLoop *) currentRunLoop;
+ (NSRunLoop *) mainRunLoop;

//
// this may return "nil" when the thread is going down and will not create
// a spurious runloop (useful for -finalize/-dealloc kinda code)
//
+ (NSRunLoop *) mulleCurrentRunLoop;

- (NSRunLoopMode) currentMode;

- (void) acceptInputForMode:(NSRunLoopMode) modeName
                 beforeDate:(NSDate *) limitDate;

- (void) run;
- (void) runUntilDate:(NSDate *) limitDate;
- (BOOL) runMode:(NSRunLoopMode) modeName
      beforeDate:(NSDate *) limitDate;

- (NSDate *) limitDateForMode:(NSRunLoopMode) modeName;

// Messages
- (void) performSelector:(SEL) aSelector
                  target:(id) target
                argument:(id) arg
                   order:(NSUInteger) order
                   modes:(NSArray *) modes;

- (void) cancelPerformSelector:(SEL) aSelector
                        target:(id) target
                      argument:(id) arg;
- (void) cancelPerformSelectorsWithTarget:(id) target;

// Timer
- (void) addTimer:(NSTimer *) timer
          forMode:(NSRunLoopMode) modeName;

@end


enum MulleRunLoopInputState
{
   MulleRunLoopTimeout             = 0,
   MulleRunLoopInputReceived       = 1,
   MulleRunLoopNoTimersOrInputLeft = 2
};



@interface NSRunLoop( Future)

- (enum MulleRunLoopInputState) _acceptInputForRunLoopMode:(struct MulleRunLoopMode *) mode
                                                beforeDate:(NSDate *) limitDate;
@end


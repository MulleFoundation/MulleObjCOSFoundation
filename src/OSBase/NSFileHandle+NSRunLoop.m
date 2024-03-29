/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSFileHandle.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSFileHandle+NSRunLoop.h"

#import "NSRunLoop.h"
#import "NSRunLoop-Private.h"

#import "NSPageAllocation.h"


NSString  *NSFileHandleReadCompletionNotification = @"NSFileHandleReadCompletionNotification";

// why should I put this into the info dict again ?
NSString  *NSFileHandleNotificationFileHandleItem = @"fileHandle";
NSString  *NSFileHandleNotificationDataItem       = @"data";

//
// we don't dot these yet, or maybe never because file reading with callbacks
// is just not very nice
//
NSString *NSFileHandleConnectionAcceptedNotification        = @"NSFileHandleConnectionAcceptedNotification";
NSString *NSFileHandleDataAvailableNotification             = @"NSFileHandleDataAvailableNotification";
NSString *NSFileHandleReadToEndOfFileCompletionNotification = @"NSFileHandleReadToEndOfFileCompletionNotification";


@interface NSFileHandle( _NSFileDescriptor)  < _NSFileDescriptor>

- (void) _notifyWithRunLoop:(NSRunLoop *) runloop;

@end


@implementation NSFileHandle( _NSFileDescriptor)

// the runloop notifies us, that there is stuff to read
- (void) _notifyWithRunLoop:(NSRunLoop *) runloop
{
   NSData         *data;
   NSDictionary   *info;

   data = [self availableData];
   info = [NSDictionary dictionaryWithObject:data
                                      forKey:NSFileHandleNotificationDataItem];
   [[NSNotificationCenter defaultCenter]
    postNotificationName:NSFileHandleReadCompletionNotification
                  object:self
                userInfo:info];
}

@end


@implementation NSFileHandle( NSRunLoop)

- (void) readInBackgroundAndNotify
{
   [[NSRunLoop currentRunLoop] _addObject:self
                                  forMode:NSDefaultRunLoopMode];
}


- (void) readInBackgroundAndNotifyForModes:(NSArray *) modes
{
   NSRunLoop      *runloop;
   NSRunLoopMode   modeName;

   runloop = [NSRunLoop currentRunLoop];
   for( modeName in modes)
      [runloop _addObject:self
                  forMode:modeName];
}

@end


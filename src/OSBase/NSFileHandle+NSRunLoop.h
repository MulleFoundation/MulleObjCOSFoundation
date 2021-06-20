//
//  NSFileHandle+NSRunLoop.h
//  MulleObjCOSFoundation
//
//  Created by Nat! on 04.04.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
#import "NSFileHandle.h"


@class NSRunLoop;


@interface NSFileHandle( NSRunLoop)

- (void) readInBackgroundAndNotify;
- (void) readInBackgroundAndNotifyForModes:(NSArray *) modes;

@end

// unused but defined to get thinks to link
extern NSString  *NSFileHandleConnectionAcceptedNotification;
extern NSString  *NSFileHandleDataAvailableNotification;
extern NSString  *NSFileHandleReadToEndOfFileCompletionNotification;


extern NSString  *NSFileHandleReadCompletionNotification;

extern NSString  *NSFileHandleNotificationDataItem;
extern NSString  *NSFileHandleNotificationFileHandleItem;

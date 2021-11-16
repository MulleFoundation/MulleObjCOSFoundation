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
MULLE_OBJC_OSBASE_FOUNDATION_EXTERN_GLOBAL
NSString  *NSFileHandleConnectionAcceptedNotification;

MULLE_OBJC_OSBASE_FOUNDATION_EXTERN_GLOBAL
NSString  *NSFileHandleDataAvailableNotification;

MULLE_OBJC_OSBASE_FOUNDATION_EXTERN_GLOBAL
NSString  *NSFileHandleReadToEndOfFileCompletionNotification;


MULLE_OBJC_OSBASE_FOUNDATION_EXTERN_GLOBAL
NSString  *NSFileHandleReadCompletionNotification;

MULLE_OBJC_OSBASE_FOUNDATION_EXTERN_GLOBAL
NSString  *NSFileHandleNotificationDataItem;

MULLE_OBJC_OSBASE_FOUNDATION_EXTERN_GLOBAL
NSString  *NSFileHandleNotificationFileHandleItem;

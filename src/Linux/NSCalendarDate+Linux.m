//
//  NSCalendarDate+Linux.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 04.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#define _GNU_SOURCE

#import "import-private.h"

// other files in this library
#import <MulleObjCPosixFoundation/NSDate+Posix-Private.h>

// other libraries of MulleObjCPosixFoundation
#import <MulleObjCStandardFoundation/_MulleObjCConcreteCalendarDate.h>

// std-c and dependencies
#include <time.h>


@interface NSTimeZone( Posix)

- (NSInteger) mulleSecondsFromGMTForTimeIntervalSince1970:(NSTimeInterval) interval;

@end


@implementation NSCalendarDate( Linux)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCPosixFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}


// EMPTY


@end


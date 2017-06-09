//
//  NSProcessInfo+BSD.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 06.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#define _DARWIN_C_SOURCE

#import "MulleObjCPosixFoundation.h"

// other files in this library

// std-c and dependencies
#include <stdlib.h>



@implementation NSProcessInfo( BSD)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( Posix) },
      { 0, 0 }
   };

   return( dependencies);
}


- (NSString *) processName
{
   return( [NSString stringWithCString:(char *) getprogname()]);
}


- (void) setProcessName:(NSString *) name
{
   setprogname( [name cString]);
}

@end

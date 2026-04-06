//
//  NSProcessInfo+BSD.m
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 06.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#define _DARWIN_C_SOURCE

#import "import-private.h"

// other files in this library

// std-c and dependencies
#include <stdlib.h>



@implementation NSProcessInfo( BSD)

@dependency NSProcessInfo( Posix);


- (NSString *) processName
{
   return( [NSString stringWithCString:(char *) getprogname()]);
}


- (void) setProcessName:(NSString *) name
{
   char   *s;

   // unavoidable leak (see setprogname man page)
   s = mulle_allocator_strdup( &mulle_stdlib_allocator, [name cString]);
   setprogname( s);
}

@end

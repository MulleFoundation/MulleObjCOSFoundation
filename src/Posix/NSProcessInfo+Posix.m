//
//  NSProcessInfo+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#define _XOPEN_SOURCE 700

#import "import-private.h"

// other files in this library
#import "NSError+Posix.h"


// std-c and dependencies
#include <unistd.h>


@implementation NSProcessInfo (Posix)

- (int) processIdentifier
{
   MulleObjCSetPosixErrorDomain();

   return( getpid());
}

- (void) mulleSetEnvironmentValue:(NSString *) value 
                           forKey:(NSString *) key
{
   NSMutableDictionary   *dict;

   // environment is lazy
   dict = _environment 
          ? [NSMutableDictionary dictionaryWithDictionary:_environment]
          : nil;
   if( value)
   {
      if( setenv( [key cString], [value cString], 1))
         MulleObjCThrowErrnoException( @"setenv");
      [dict setObject:value
              forKey:key];
   }
   else
   {
      if( unsetenv( [key cString]))
         MulleObjCThrowErrnoException( @"unsetenv");
      [dict removeObjectForKey:key];
   }
   
   [_environment autorelease];
   _environment = [dict retain];
}                           

@end

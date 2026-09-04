//
//  NSLog.m
//  MulleObjCOSFoundation
//
//  Copyright (c) 2016 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
#define _XOPEN_SOURCE 700

#import "import-private.h"

#import "NSLog.h"
// other files in this library

// std-c and dependencies
#include <syslog.h>


// TODO: vectorize NSLog like PathUtilities

int  __NSLogPriority = LOG_WARNING;


//void  NSLogName( NSString *s)
//{
//   char   *name;
//
//   name = strdup( [s UTF8String]);  // sic!
//   openlog( name, LOG_ERR|LOG_PID, LOG_USER);
//}


void   NSLog( NSString *format, ...)
{
   va_list   args;

   //NSPushAutoreleasePool( 0);

   va_start( args, format );
   NSLogv( format, args);
   va_end( args);

   //NSPopAutoreleasePool();
}


void   NSLogv( NSString *format, va_list args)
{
   NSString  *s;
   char      *cString;

   //
   // the autoreleasepool is here, because we assume there are
   // %@ arguments in the format, which will often lead to the creation of many
   // temporary little strings (via description)
   //
   @autoreleasepool
   {
      s = [NSString mulleStringWithFormat:format
                                arguments:args];
      cString = [s cString];
      mulle_fprintf( stderr, "%s\n", cString);  // this first i'd say
      syslog( __NSLogPriority, "%s", cString);
   }
}


void   NSLogArguments( NSString *format, mulle_vararg_list args)
{
   NSString   *s;
   char       *cString;

   @autoreleasepool
   {
      s = [NSString stringWithFormat:format
                     mulleVarargList:args];
      cString = [s cString];
      syslog( __NSLogPriority, "%s", cString);
      mulle_fprintf( stderr, "%s\n", cString);
   }
}


//
// a category is cheaper than a class and it can have its own unload
//
@implementation NSProcessInfo( SyslogUnloader)

+ (void) unload
{
   closelog();
}

@end

/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSLog.m is a part of MulleObjCOSFoundation
 *
 *  Copyright (C) 2024 Mulle kybernetiK.
 *  All rights reserved.
 *
 */

#import "import-private.h"

#import "NSLog.h"

// Windows headers
#include <windows.h>


void   NSLog( NSString *format, ...)
{
   va_list   args;

   va_start( args, format);
   NSLogv( format, args);
   va_end( args);
}


void   NSLogv( NSString *format, va_list args)
{
   NSString  *s;
   char      *cString;

   @autoreleasepool
   {
      s = [NSString mulleStringWithFormat:format
                                arguments:args];
      cString = [s cString];
      mulle_fprintf( stderr, "%s\n", cString);
      OutputDebugStringA( cString);
      OutputDebugStringA( "\n");
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
      mulle_fprintf( stderr, "%s\n", cString);
      OutputDebugStringA( cString);
      OutputDebugStringA( "\n");
   }
}

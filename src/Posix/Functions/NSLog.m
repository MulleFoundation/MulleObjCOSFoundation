/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSLog.c is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#define _XOPEN_SOURCE 700

#import "import-private.h"

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

   //NSPushAutoreleasePool();

   va_start( args, format );
   NSLogv( format, args);
   va_end( args);

   //NSPopAutoreleasePool();
}


void   NSLogv( NSString *format, va_list args)
{
   NSString  *s;
   char      *cString;

   s = [NSString stringWithFormat:format
                       arguments:args];
   cString = [s cString];
   syslog( __NSLogPriority, "%s", cString);
   fprintf( stderr, "%s\n", cString);
}


void   NSLogArguments( NSString *format, mulle_vararg_list args)
{
   NSString  *s;
   char      *cString;

   s = [NSString stringWithFormat:format
                  mulleVarargList:args];
   cString = [s cString];
   syslog( __NSLogPriority, "%s", cString);
   fprintf( stderr, "%s\n", cString);
}

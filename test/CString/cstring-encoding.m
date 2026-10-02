//
//  cstring-encoding.m
//  MulleObjCOSFoundation
//
//  Regression test: the process is run in a UTF-8 character locale, so the C
//  library hands back UTF-8 and the C string encoding is UTF-8. It is NOT
//  adapted to the language of the user; only on a system that can not do
//  UTF-8 at all would the encoding be something else.
//
//  Nothing in this test calls setlocale(). The premise of the test is that
//  the foundation has already established the locale at load time - without
//  that nl_langinfo( CODESET) of a fresh process reports the "C" codeset
//  (ANSI_X3.4-1968) on every system.
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef _WIN32
#include <langinfo.h>
#include <locale.h>
#endif


static void   dump( char *tag, BOOL flag)
{
   mulle_printf( "%s=%s\n", tag, flag ? "YES" : "NO");
}


int   main( int argc, const char * argv[])
{
   NSString   *s;
   char       buf[ 32];

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
#ifndef _WIN32
      dump( "process-locale-is-utf8",
            ! strcmp( nl_langinfo( CODESET), "UTF-8"));
#else
      // there is no process locale on Windows, the code page is fixed
      dump( "process-locale-is-utf8", YES);
#endif

      dump( "cstring-encoding-is-utf8",
            [NSString defaultCStringEncoding] == NSUTF8StringEncoding);

      // the class method and the instance method must agree
      dump( "class-matches-instance",
            [NSString defaultCStringEncoding] == [@"x" _cStringEncoding]);

      // ASCII round trips through the C string encoding
      s = [NSString stringWithCString:"hello"];
      dump( "ascii-roundtrip", [s isEqualToString:@"hello"]);

      [s getCString:buf maxLength:sizeof( buf)];
      dump( "getcstring-ascii", ! strcmp( buf, "hello"));
   }

   return( 0);
}

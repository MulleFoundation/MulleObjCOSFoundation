//
//  lossy-cstring.m
//  MulleObjCOSFoundation
//
//  Regression test: a C string can contain bytes that are not valid in the
//  C string encoding (a legacy encoded locale string for instance, like
//  zh_CN.eucCN's monetary data). Converting such a string must not abort the
//  process - the offending bytes are replaced with '?' instead.
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


#include <stdio.h>


static void   dump( char *tag, NSString *s)
{
   mulle_printf( "%s=%s\n", tag, s ? [s UTF8String] : "(nil)");
}


int   main( int argc, const char * argv[])
{
   NSString   *s;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      // a lone continuation byte and two illegal lead bytes are not UTF-8
      dump( "single", [NSString stringWithCString:"\x80"]);
      dump( "pair", [NSString stringWithCString:"\xff\xfe"]);

      // valid input must come through unchanged
      dump( "ascii", [NSString stringWithCString:"hello"]);
      dump( "empty-length",
            [NSString stringWithFormat:@"%lu", (unsigned long)
               [[NSString stringWithCString:""] length]]);

      s = [NSString stringWithCString:"caf\xc3\xa9"];  // "café" in UTF-8
      mulle_printf( "utf8-preserved=%s\n",
         [s isEqualToString:[NSString stringWithUTF8String:"caf\xc3\xa9"]] ? "YES" : "NO");
   }

   return( 0);
}

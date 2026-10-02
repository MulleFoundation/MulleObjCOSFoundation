//
//  file-system-representation.m
//  MulleObjCOSFoundation
//
//  The two halves of the file system representation must round trip:
//  whatever charset the platform uses for paths, converting a path out and
//  back in again must return the same path.
//
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

#include <stdio.h>
#include <string.h>


static void   pass( char *tag, BOOL flag)
{
   mulle_printf( "%s=%s\n", tag, flag ? "YES" : "NO");
}


static void   fail( char *tag)
{
   mulle_printf( "%s=FAIL\n", tag);
}


int   main( int argc, const char * argv[])
{
   NSFileManager   *fm;
   NSString        *path;
   NSString        *back;
   char            *bytes;

#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   @autoreleasepool
   {
      fm   = [NSFileManager defaultManager];
      path = @"Grüße/日本語/path.txt";

      bytes = [fm fileSystemRepresentationWithPath:path];
      back  = [fm stringWithFileSystemRepresentation:bytes
                                              length:bytes ? strlen( bytes) : 0];

      pass( "fs-roundtrip", back && [back isEqualToString:path]);

      // A POSIX path is a byte string, so it can contain bytes that are not
      // valid in the platform charset. Those are substituted, like everywhere
      // else, instead of raising. Windows has its own path representation
      // (UTF-16), where this can not arise.
#ifndef _WIN32
      {
         char        broken[] = { 'n', 'a', (char) 0xff, 'm', 'e', 0 };
         NSString   *fixed;

         fixed = [fm stringWithFileSystemRepresentation:broken
                                                 length:strlen( broken)];
         if( ! fixed || ![fixed isEqualToString:@"na?me"])
            fail( "fs-broken-bytes-substituted");
      }
#endif
   }

   return( 0);
}

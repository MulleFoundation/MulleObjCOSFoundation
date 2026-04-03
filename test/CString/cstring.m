
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


#include <stdio.h>



int   main( int argc, const char * argv[])
{
   NSString   *cString;

   cString = [[[NSString alloc] initWithUTF8String:""] autorelease];

   if( [cString length] != 0)
      mulle_printf( "FAIL\n");
   if( [cString cStringLength] != 0)
      mulle_printf( "FAIL\n");

   cString = [[[NSString alloc] initWithUTF8String:"VfL"] autorelease];

   if( [cString length] != 3)
      mulle_printf( "FAIL\n");
   if( [cString cStringLength] != 3)
      mulle_printf( "FAIL\n");

   cString = [[[NSString alloc] initWithUTF8String:"VfL"] autorelease];

   if( [cString length] != 3)
      mulle_printf( "FAIL\n");
   if( [cString cStringLength] != 3)
      mulle_printf( "FAIL\n");

   return( 0);
}

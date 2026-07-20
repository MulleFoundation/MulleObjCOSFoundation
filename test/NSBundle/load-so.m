#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

#ifdef _WIN32
int   main( int argc, char *argv[])
{
   mulle_printf( "PASS\n");
   return( 0);
}
#else
#include <dlfcn.h>

int   main( int argc, char *argv[])
{
   NSBundle   *bundle;
   void       *sym;

   bundle = [[[NSBundle alloc] initWithPath:@"/usr/lib/x86_64-linux-gnu/libm.so.6"] autorelease];
   if( ! bundle)
   {
      mulle_printf( "FAIL: could not create bundle\n");
      return( 1);
   }

   if( ! [bundle loadBundle])
   {
      mulle_printf( "FAIL: could not load bundle\n");
      return( 1);
   }

   sym = [bundle mulleLookupSymbolUTF8String:"cos"];
   if( ! sym)
   {
      mulle_printf( "FAIL: could not find cos symbol\n");
      return( 1);
   }

   sym = [bundle mulleLookupSymbol:@"sin"];
   if( ! sym)
   {
      mulle_printf( "FAIL: could not find sin symbol\n");
      return( 1);
   }

   // ensure unknown symbol returns NULL
   sym = [bundle mulleLookupSymbolUTF8String:"__nonexistent_symbol_xyz__"];
   if( sym)
   {
      mulle_printf( "FAIL: found nonexistent symbol\n");
      return( 1);
   }

   mulle_printf( "PASS\n");
   return( 0);
}
#endif

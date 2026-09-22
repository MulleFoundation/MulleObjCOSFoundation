#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSUInteger   page;
   NSUInteger   logPage;
   void         *ptr;

   page    = NSPageSize();
   logPage = NSLogPageSize();

   show( @"page-positive", page > 0);
   show( @"logpage-positive", logPage > 0);
   show( @"logpage-le-page", logPage <= page);

   show( @"roundup-page", NSRoundUpToMultipleOfPageSize( page) == page);
   show( @"roundup-page1", NSRoundUpToMultipleOfPageSize( page + 1) == page * 2);
   show( @"rounddown-page", NSRoundDownToMultipleOfPageSize( page) == page);
   show( @"rounddown-page1", NSRoundDownToMultipleOfPageSize( page + 1) == page);

   ptr = NSAllocateMemoryPages( page);
   show( @"allocate", ptr != NULL);
   NSDeallocateMemoryPages( ptr, page);

   return( 0);
}

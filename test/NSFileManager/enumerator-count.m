#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSFileManager           *fileManager;
   NSDirectoryEnumerator   *enumerator;
   NSUInteger              count;

   fileManager = [NSFileManager defaultManager];

   [fileManager removeItemAtPath:@"enum-count-tree" error:NULL];
   [fileManager createDirectoryAtPath:@"enum-count-tree/d1/d2"
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];
   [fileManager createFileAtPath:@"enum-count-tree/a" contents:[NSData data] attributes:nil];
   [fileManager createFileAtPath:@"enum-count-tree/d1/b" contents:[NSData data] attributes:nil];
   [fileManager createFileAtPath:@"enum-count-tree/d1/d2/c" contents:[NSData data] attributes:nil];
   [fileManager createSymbolicLinkAtPath:@"enum-count-tree/lf" pathContent:@"a"];

   // count is the total number of objects and does not consume the receiver
   enumerator = [fileManager enumeratorAtPath:@"enum-count-tree"];
   count      = [enumerator count];
   mulle_printf( "count=%d\n", (int) count);
   show( @"still.enumerates", [enumerator nextObject] != nil);

   // a nonexistent path yields an enumerator that counts zero
   enumerator = [fileManager enumeratorAtPath:@"enum-count-tree/nope"];
   show( @"nonexistent.count.zero", enumerator == nil || [enumerator count] == 0);

   [fileManager removeItemAtPath:@"enum-count-tree" error:NULL];
   return( 0);
}

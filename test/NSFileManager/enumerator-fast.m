#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSFileManager           *fileManager;
   NSDirectoryEnumerator   *enumerator;
   NSMutableArray          *collected;
   NSArray                 *names;
   id                      obj;
   NSUInteger              count;

   fileManager = [NSFileManager defaultManager];

   [fileManager removeItemAtPath:@"enum-fast-tree" error:NULL];
   [fileManager createDirectoryAtPath:@"enum-fast-tree/d1/d2"
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];
   [fileManager createFileAtPath:@"enum-fast-tree/a" contents:[NSData data] attributes:nil];
   [fileManager createFileAtPath:@"enum-fast-tree/d1/b" contents:[NSData data] attributes:nil];
   [fileManager createFileAtPath:@"enum-fast-tree/d1/d2/c" contents:[NSData data] attributes:nil];
   [fileManager createSymbolicLinkAtPath:@"enum-fast-tree/lf" pathContent:@"a"];

   // fast enumeration
   collected = [NSMutableArray array];
   count     = 0;
   for( obj in [fileManager enumeratorAtPath:@"enum-fast-tree"])
   {
      [collected addObject:obj];
      count++;
   }
   names = [collected sortedArrayUsingSelector:@selector( compare:)];
   mulle_printf( "fast.count=%d\n", (int) count);
   mulle_printf( "fast.contents=<%s>\n", [[names componentsJoinedByString:@","] UTF8String]);
   show( @"fast.lf.present", [names containsObject:@"lf"]);

   // skipDescendants before the first nextObject is harmless
   count      = 0;
   enumerator = [fileManager enumeratorAtPath:@"enum-fast-tree"];
   [enumerator skipDescendants];
   while( (obj = [enumerator nextObject]))
      count++;
   mulle_printf( "skip.before.count=%d\n", (int) count);

   // a nonexistent path yields nothing
   enumerator = [fileManager enumeratorAtPath:@"enum-fast-tree/nope"];
   show( @"nonexistent", enumerator == nil || [enumerator nextObject] == nil);

   [fileManager removeItemAtPath:@"enum-fast-tree" error:NULL];
   return( 0);
}

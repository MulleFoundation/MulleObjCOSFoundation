#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


static BOOL   typeIs( NSDictionary *attributes, NSString *type)
{
   return( [[attributes objectForKey:NSFileType] isEqualToString:type]);
}


int   main( int argc, char *argv[])
{
   NSFileManager           *fileManager;
   NSDirectoryEnumerator   *enumerator;
   NSMutableDictionary     *levels;
   NSDictionary            *attributes;
   id                      obj;
   NSUInteger              count;
   BOOL                    bIsRegular;
   BOOL                    d2IsDir;

   fileManager = [NSFileManager defaultManager];

   [fileManager removeItemAtPath:@"enum-deep-tree" error:NULL];
   [fileManager createDirectoryAtPath:@"enum-deep-tree/d1/d2/d3"
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];
   [fileManager createDirectoryAtPath:@"empty"
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];
   [fileManager createFileAtPath:@"enum-deep-tree/a" contents:[NSData data] attributes:nil];
   [fileManager createFileAtPath:@"enum-deep-tree/d1/b" contents:[NSData data] attributes:nil];
   [fileManager createFileAtPath:@"enum-deep-tree/d1/d2/c" contents:[NSData data] attributes:nil];
   [fileManager createFileAtPath:@"enum-deep-tree/d1/d2/d3/e" contents:[NSData data] attributes:nil];

   levels = [NSMutableDictionary dictionary];
   enumerator = [fileManager enumeratorAtPath:@"enum-deep-tree"];
   while( (obj = [enumerator nextObject]))
      [levels setObject:[NSNumber numberWithInteger:[enumerator level]]
                 forKey:obj];

   count = [levels count];
   mulle_printf( "enum.count=%d\n", (int) count);
   mulle_printf( "level.a=%d\n", [[levels objectForKey:@"a"] intValue]);
   mulle_printf( "level.d1=%d\n", [[levels objectForKey:@"d1"] intValue]);
   mulle_printf( "level.d1.b=%d\n", [[levels objectForKey:@"d1/b"] intValue]);
   mulle_printf( "level.d1.d2=%d\n", [[levels objectForKey:@"d1/d2"] intValue]);
   mulle_printf( "level.d1.d2.c=%d\n", [[levels objectForKey:@"d1/d2/c"] intValue]);
   mulle_printf( "level.d1.d2.d3=%d\n", [[levels objectForKey:@"d1/d2/d3"] intValue]);
   mulle_printf( "level.d1.d2.d3.e=%d\n", [[levels objectForKey:@"d1/d2/d3/e"] intValue]);

   // skipDescendants hides the contents of d1
   levels = [NSMutableDictionary dictionary];
   enumerator = [fileManager enumeratorAtPath:@"enum-deep-tree"];
   while( (obj = [enumerator nextObject]))
   {
      [levels setObject:obj forKey:obj];
      if( [obj isEqualToString:@"d1"])
         [enumerator skipDescendants];
   }
   mulle_printf( "skip.count=%d\n", (int) [levels count]);
   mulle_printf( "skip.d1.b.gone=%d\n", [levels objectForKey:@"d1/b"] == nil);

   // alternate spelling
   levels = [NSMutableDictionary dictionary];
   enumerator = [fileManager enumeratorAtPath:@"enum-deep-tree"];
   while( (obj = [enumerator nextObject]))
   {
      [levels setObject:obj forKey:obj];
      if( [obj isEqualToString:@"d1"])
         [enumerator skipDescendents];
   }
   mulle_printf( "skipdescendents.count=%d\n", (int) [levels count]);

   // per item attributes
   bIsRegular = NO;
   d2IsDir    = NO;
   enumerator = [fileManager enumeratorAtPath:@"enum-deep-tree"];
   while( (obj = [enumerator nextObject]))
   {
      if( [obj isEqualToString:@"d1/b"])
         bIsRegular = typeIs( [enumerator fileAttributes], NSFileTypeRegular);
      if( [obj isEqualToString:@"d1/d2"])
         d2IsDir = typeIs( [enumerator fileAttributes], NSFileTypeDirectory);
   }
   show( @"fileattrs.b.regular", bIsRegular);
   show( @"fileattrs.d2.dir", d2IsDir);

   attributes = [[fileManager enumeratorAtPath:@"enum-deep-tree"] directoryAttributes];
   show( @"dirattrs.dir", typeIs( attributes, NSFileTypeDirectory));

   // empty directory
   count = [[[fileManager enumeratorAtPath:@"empty"] allObjects] count];
   mulle_printf( "empty.count=%d\n", (int) count);

   // a filename yields an empty enumerator
   enumerator = [fileManager enumeratorAtPath:@"enum-deep-tree/a"];
   show( @"file.enum.notnil", enumerator != nil);
   show( @"file.enum.first.nil", [enumerator nextObject] == nil);

   [fileManager removeItemAtPath:@"enum-deep-tree" error:NULL];
   [fileManager removeItemAtPath:@"empty" error:NULL];
   return( 0);
}

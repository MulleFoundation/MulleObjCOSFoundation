#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


static BOOL   typeIs( NSDictionary *attributes, NSString *type)
{
   return( [[attributes objectForKey:NSFileType] isEqualToString:type]);
}


static NSMutableDictionary   *enumerate( NSString *path, BOOL skip)
{
   NSDirectoryEnumerator   *enumerator;
   NSMutableDictionary     *levels;
   id                      obj;

   enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
   levels     = [NSMutableDictionary dictionary];

   while( (obj = [enumerator nextObject]))
   {
      [levels setObject:[NSNumber numberWithInteger:[enumerator level]]
                 forKey:obj];
      if( skip && [obj isEqualToString:@"sub"])
         [enumerator skipDescendants];
   }

   return( levels);
}


int   main( int argc, char *argv[])
{
   NSFileManager           *fileManager;
   NSDirectoryEnumerator   *enumerator;
   NSMutableDictionary     *levels;
   NSDictionary            *attributes;
   id                      obj;

   fileManager = [NSFileManager defaultManager];

   [fileManager removeItemAtPath:@"enum-tree" error:NULL];
   [fileManager createDirectoryAtPath:@"enum-tree"
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];
   [fileManager createFileAtPath:@"enum-tree/a" contents:[NSData data] attributes:nil];
   [fileManager createDirectoryAtPath:@"enum-tree/sub"
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];
   [fileManager createFileAtPath:@"enum-tree/sub/b" contents:[NSData data] attributes:nil];
   [fileManager createSymbolicLinkAtPath:@"enum-tree/sub2" pathContent:@"sub"];

   levels = enumerate( @"enum-tree", NO);
   show( @"enum.a", [levels objectForKey:@"a"] != nil);
   show( @"enum.sub", [levels objectForKey:@"sub"] != nil);
   show( @"enum.sub.b", [levels objectForKey:@"sub/b"] != nil);
   show( @"enum.sub2", [levels objectForKey:@"sub2"] != nil);
   show( @"enum.sub2.b.gone", [levels objectForKey:@"sub2/b"] == nil);
   mulle_printf( "level.a=%d\n", [[levels objectForKey:@"a"] intValue]);
   mulle_printf( "level.sub=%d\n", [[levels objectForKey:@"sub"] intValue]);
   mulle_printf( "level.sub.b=%d\n", [[levels objectForKey:@"sub/b"] intValue]);
   mulle_printf( "level.sub2=%d\n", [[levels objectForKey:@"sub2"] intValue]);

   levels = enumerate( @"enum-tree", YES);
   show( @"skip.sub", [levels objectForKey:@"sub"] != nil);
   show( @"skip.sub.b.gone", [levels objectForKey:@"sub/b"] == nil);

   // attributes of the directory and the current item
   enumerator = [fileManager enumeratorAtPath:@"enum-tree"];
   show( @"dirattrs.isdir", typeIs( [enumerator directoryAttributes], NSFileTypeDirectory));
   obj = [enumerator nextObject];
   show( @"fileattrs.notnil", obj != nil && [enumerator fileAttributes] != nil);

   [fileManager removeItemAtPath:@"enum-tree" error:NULL];
   return( 0);
}

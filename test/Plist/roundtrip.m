#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSFileManager   *fileManager;
   NSArray         *array;
   NSArray         *array2;
   NSDictionary    *dictionary;
   NSDictionary    *dictionary2;
   NSData          *data;
   NSData          *data2;

   fileManager = [NSFileManager defaultManager];

   dictionary = @{ @"a": @"x", @"b": @"y" };
   show( @"dict-write", [dictionary writeToFile:@"plist-dict.plist"
                                     atomically:NO]);
   dictionary2 = [NSDictionary dictionaryWithContentsOfFile:@"plist-dict.plist"];
   show( @"dict-read", [dictionary2 isEqualToDictionary:dictionary]);

   array = @[ @"a", @"b", @"c" ];
   show( @"array-write", [array writeToFile:@"plist-array.plist"
                                atomically:NO]);
   array2 = [NSArray arrayWithContentsOfFile:@"plist-array.plist"];
   show( @"array-read", [array2 isEqualToArray:array]);

   data = [NSData dataWithBytes:"xyz" length:3];
   show( @"data-write", [data writeToFile:@"plist-data"
                              atomically:NO]);
   data2 = [NSData dataWithContentsOfFile:@"plist-data"];
   show( @"data-read", [data2 isEqualToData:data]);

   [fileManager removeItemAtPath:@"plist-dict.plist" error:NULL];
   [fileManager removeItemAtPath:@"plist-array.plist" error:NULL];
   [fileManager removeItemAtPath:@"plist-data" error:NULL];

   return( 0);
}

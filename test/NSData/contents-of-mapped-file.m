#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSFileManager   *fileManager;
   NSData          *data;
   NSData          *expected;
   NSData          *missing;
   NSMutableData   *mutableData;

   fileManager = [NSFileManager defaultManager];

   [[NSData dataWithBytes:"hello world" length:11] writeToFile:@"mapped"
                                                     atomically:NO];

   expected = [NSData dataWithBytes:"hello world" length:11];

   data = [NSData dataWithContentsOfMappedFile:@"mapped"];
   show( @"mapped-non-nil", data != nil);
   show( @"mapped-length", [data length] == 11);
   show( @"mapped-bytes", [data isEqualToData:expected]);

   data = [[[NSData alloc] initWithContentsOfMappedFile:@"mapped"] autorelease];
   show( @"init-mapped-length", [data length] == 11);

   mutableData = [[[NSMutableData alloc] initWithContentsOfMappedFile:@"mapped"] autorelease];
   show( @"mutable-mapped-length", [mutableData length] == 11);

   missing = [NSData dataWithContentsOfMappedFile:@"mapped-nope"];
   show( @"mapped-missing-nil", missing == nil);

   [fileManager removeItemAtPath:@"mapped" error:NULL];

   return( 0);
}

#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


static NSData   *dataOfLength( NSUInteger n, unsigned char seed)
{
   unsigned char   *buf;
   NSData          *data;
   NSUInteger      i;

   buf = malloc( n ? n : 1);
   for( i = 0; i < n; i++)
      buf[ i] = (unsigned char) (seed + i);
   data = [NSData dataWithBytes:buf
                         length:n];
   free( buf);
   return( data);
}


static BOOL   roundtrip( NSString *path, NSData *data, BOOL atomically)
{
   NSData   *read;

   if( ! [data writeToFile:path
                atomically:atomically])
      return( NO);

   read = [NSData dataWithContentsOfFile:path];
   return( [read isEqualToData:data]);
}


int   main( int argc, char *argv[])
{
   NSFileManager   *fileManager;
   NSData          *data;

   fileManager = [NSFileManager defaultManager];

   [fileManager removeItemAtPath:@"data" error:NULL];
   [fileManager createDirectoryAtPath:@"data"
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];

   data = dataOfLength( 10, 1);
   show( @"roundtrip.small", roundtrip( @"data/small", data, NO));
   show( @"roundtrip.small.atomic", roundtrip( @"data/small", data, YES));

   data = dataOfLength( 0x1000, 2);
   show( @"roundtrip.4096", roundtrip( @"data/page", data, NO));

   data = dataOfLength( 10000, 3);
   show( @"roundtrip.big", roundtrip( @"data/big", data, NO));

   data = dataOfLength( 0, 4);
   show( @"roundtrip.empty", roundtrip( @"data/empty", data, NO));

   show( @"read.none.isnil", [NSData dataWithContentsOfFile:@"data/nope"] == nil);
   show( @"read.dir.isnil", [NSData dataWithContentsOfFile:@"data"] == nil);
   show( @"write.badpath", [data writeToFile:@"nodir/x"
                                  atomically:NO] == NO);

   [fileManager removeItemAtPath:@"data" error:NULL];
   return( 0);
}

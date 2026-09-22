#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


static BOOL   dataIs( NSData *data, void *bytes, NSUInteger len)
{
   return( [data isEqualToData:[NSData dataWithBytes:bytes
                                              length:len]]);
}


static BOOL   fileIs( NSString *path, void *bytes, NSUInteger len)
{
   return( dataIs( [NSData dataWithContentsOfFile:path], bytes, len));
}


int   main( int argc, char *argv[])
{
   NSFileManager   *fileManager;
   NSFileHandle    *fileHandle;
   NSData          *data;

   fileManager = [NSFileManager defaultManager];

   [fileManager removeItemAtPath:@"fh" error:NULL];
   [fileManager createDirectoryAtPath:@"fh"
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];

   [[NSData dataWithBytes:"hello" length:5] writeToFile:@"fh/a"
                                             atomically:NO];

   fileHandle = [NSFileHandle fileHandleForReadingAtPath:@"fh/a"];
   show( @"open.read", fileHandle != nil);

   data = [fileHandle readDataOfLength:2];
   show( @"read.2", dataIs( data, "he", 2));

   data = [fileHandle readDataOfLength:10];
   show( @"read.rest", dataIs( data, "llo", 3));

   data = [fileHandle readDataOfLength:5];
   show( @"read.eof.empty", data != nil && [data length] == 0);

   data = [fileHandle readDataToEndOfFile];
   show( @"read.end.empty", data != nil && [data length] == 0);

   show( @"offset.5", [fileHandle offsetInFile] == 5);

   [fileHandle seekToFileOffset:1];
   show( @"offset.1", [fileHandle offsetInFile] == 1);

   data = [fileHandle readDataOfLength:3];
   show( @"read.ell", dataIs( data, "ell", 3));

   show( @"seek.end", [fileHandle seekToEndOfFile] == 5);
   [fileHandle closeFile];

   show( @"open.read.missing", [NSFileHandle fileHandleForReadingAtPath:@"fh/nope"] == nil);
   show( @"open.write.missing", [NSFileHandle fileHandleForWritingAtPath:@"fh/nope"] == nil);

   // write over existing content
   fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:@"fh/a"];
   [fileHandle writeData:[NSData dataWithBytes:"XY" length:2]];
   [fileHandle closeFile];
   show( @"write.xyllo", fileIs( @"fh/a", "XYllo", 5));

   // truncate
   [[NSData dataWithBytes:"hello" length:5] writeToFile:@"fh/b"
                                             atomically:NO];
   fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:@"fh/b"];
   [fileHandle truncateFileAtOffset:3];
   show( @"truncate.offset", [fileHandle offsetInFile] == 3);
   [fileHandle closeFile];
   show( @"truncate.len", fileIs( @"fh/b", "hel", 3));

   [fileManager removeItemAtPath:@"fh" error:NULL];
   return( 0);
}

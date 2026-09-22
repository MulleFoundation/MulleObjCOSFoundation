#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSFileManager   *fileManager;
   NSFileHandle    *fileHandle;
   NSFileHandle    *nullDevice;
   NSData          *data;
   NSData          *expected;

   fileManager = [NSFileManager defaultManager];

   [fileManager removeItemAtPath:@"fhapi" error:NULL];
   [fileManager createDirectoryAtPath:@"fhapi"
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];

   [[NSData dataWithBytes:"hello world" length:11] writeToFile:@"fhapi/a"
                                                     atomically:NO];

   // availableData reads what is there, then reports EOF
   fileHandle = [NSFileHandle fileHandleForReadingAtPath:@"fhapi/a"];
   show( @"open", fileHandle != nil);
   show( @"fd-nonneg", [fileHandle fileDescriptor] >= 0);
   data = [fileHandle availableData];
   show( @"available", [data length] == 11);
   show( @"available-offset", [fileHandle offsetInFile] == 11);
   data = [fileHandle availableData];
   show( @"available-eof-empty", [data length] == 0);
   [fileHandle closeFile];

   // zero length read does not move
   fileHandle = [NSFileHandle fileHandleForReadingAtPath:@"fhapi/a"];
   data       = [fileHandle readDataOfLength:0];
   show( @"zero-empty", [data length] == 0);
   show( @"zero-offset", [fileHandle offsetInFile] == 0);
   [fileHandle closeFile];

   // null device
   nullDevice = [NSFileHandle fileHandleWithNullDevice];
   show( @"null-fd", [nullDevice fileDescriptor] == -1);
   show( @"null-available", [[nullDevice availableData] length] == 0);
   show( @"null-to-end", [[nullDevice readDataToEndOfFile] length] == 0);
   show( @"null-of-length", [[nullDevice readDataOfLength:10] length] == 0);
   show( @"null-offset", [nullDevice offsetInFile] == 0);
   show( @"null-seek-end", [nullDevice seekToEndOfFile] == 0);

   // standard handles exist
   show( @"standard-in", [NSFileHandle fileHandleWithStandardInput] != nil);
   show( @"standard-out", [NSFileHandle fileHandleWithStandardOutput] != nil);
   show( @"standard-err", [NSFileHandle fileHandleWithStandardError] != nil);

   // write to an existing file
   [[NSData data] writeToFile:@"fhapi/w"
                   atomically:NO];
   fileHandle = [NSFileHandle fileHandleForWritingAtPath:@"fhapi/w"];
   show( @"open-write", fileHandle != nil);
   [fileHandle mulleWriteBytes:(void *) "XY"
                        length:2];
   [fileHandle synchronizeFile];
   [fileHandle closeFile];

   expected = [NSData dataWithBytes:"XY" length:2];
   data     = [NSData dataWithContentsOfFile:@"fhapi/w"];
   show( @"write-content", [data isEqualToData:expected]);

   // mulleWriteBytes with length -1 uses strlen
   [[NSData data] writeToFile:@"fhapi/w2"
                   atomically:NO];
   fileHandle = [NSFileHandle fileHandleForWritingAtPath:@"fhapi/w2"];
   [fileHandle mulleWriteBytes:(void *) "ABC"
                        length:(NSUInteger) -1];
   [fileHandle closeFile];

   expected = [NSData dataWithBytes:"ABC" length:3];
   data     = [NSData dataWithContentsOfFile:@"fhapi/w2"];
   show( @"write-strlen", [data isEqualToData:expected]);

   // state bits
   [nullDevice mulleAddToStateBits:4];
   show( @"state-bits", ([nullDevice mulleGetStateBits] & 4) == 4);

   [fileManager removeItemAtPath:@"fhapi" error:NULL];
   return( 0);
}

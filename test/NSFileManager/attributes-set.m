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
   NSFileManager   *fileManager;
   NSDictionary    *attributes;
   NSDate          *fixed;

   fileManager = [NSFileManager defaultManager];
   fixed       = [NSDate dateWithTimeIntervalSince1970:1000000000];

   [fileManager removeItemAtPath:@"attrs" error:NULL];
   [fileManager createFileAtPath:@"attrs"
                        contents:[NSData data]
                      attributes:nil];

   show( @"set.moddate", [fileManager setAttributes:@{ NSFileModificationDate: fixed }
                                      ofItemAtPath:@"attrs"
                                             error:NULL]);
   attributes = [fileManager attributesOfItemAtPath:@"attrs"
                                              error:NULL];
   show( @"get.moddate",
         (long long) [[attributes objectForKey:NSFileModificationDate] timeIntervalSince1970] == 1000000000);

   show( @"set.perms", [fileManager setAttributes:@{ NSFilePosixPermissions: @0700 }
                                    ofItemAtPath:@"attrs"
                                           error:NULL]);
   attributes = [fileManager attributesOfItemAtPath:@"attrs"
                                              error:NULL];
   show( @"get.perms", [[attributes objectForKey:NSFilePosixPermissions] unsignedIntValue] == 0700);

   show( @"type.regular", typeIs( attributes, NSFileTypeRegular));
   show( @"size.zero", [[attributes objectForKey:NSFileSize] unsignedLongLongValue] == 0);
   show( @"set.none", [fileManager setAttributes:@{ NSFilePosixPermissions: @0644 }
                                   ofItemAtPath:@"nope"
                                          error:NULL] == NO);

   [fileManager removeItemAtPath:@"attrs" error:NULL];
   return( 0);
}

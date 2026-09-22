#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSFileManager   *fileManager;
   NSData          *contents;
   BOOL            isDirectory;

   fileManager = [NSFileManager defaultManager];
   contents    = [NSData data];

   [fileManager removeItemAtPath:@"qdir" error:NULL];
   [fileManager createDirectoryAtPath:@"qdir"
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];
   [fileManager createFileAtPath:@"qdir/file"
                        contents:contents
                      attributes:nil];

   // existence
   show( @"exists.file", [fileManager fileExistsAtPath:@"qdir/file"]);
   show( @"exists.dir",  [fileManager fileExistsAtPath:@"qdir"]);
   show( @"exists.none", [fileManager fileExistsAtPath:@"qdir/nope"]);

   [fileManager fileExistsAtPath:@"qdir" isDirectory:&isDirectory];
   show( @"isdir.dir", isDirectory);
   [fileManager fileExistsAtPath:@"qdir/file" isDirectory:&isDirectory];
   show( @"isdir.file", isDirectory);

   // permissions, default file mode (0644)
   show( @"r.file", [fileManager isReadableFileAtPath:@"qdir/file"]);
   show( @"w.file", [fileManager isWritableFileAtPath:@"qdir/file"]);
   show( @"x.file", [fileManager isExecutableFileAtPath:@"qdir/file"]);
   show( @"d.file", [fileManager isDeletableFileAtPath:@"qdir/file"]);

   // permissions, file mode 0000
   [fileManager setAttributes:@{ NSFilePosixPermissions: @0000 }
                 ofItemAtPath:@"qdir/file"
                        error:NULL];
   show( @"r.file0000", [fileManager isReadableFileAtPath:@"qdir/file"]);
   show( @"w.file0000", [fileManager isWritableFileAtPath:@"qdir/file"]);
   show( @"x.file0000", [fileManager isExecutableFileAtPath:@"qdir/file"]);
   show( @"d.file0000", [fileManager isDeletableFileAtPath:@"qdir/file"]);

   [fileManager setAttributes:@{ NSFilePosixPermissions: @0644 }
                 ofItemAtPath:@"qdir/file"
                        error:NULL];

   // a directory has execute (search) privileges
   show( @"x.dir", [fileManager isExecutableFileAtPath:@"qdir"]);

   // remove
   show( @"remove.none", [fileManager removeItemAtPath:@"qdir/nope" error:NULL]);
   show( @"remove.file", [fileManager removeItemAtPath:@"qdir/file" error:NULL]);
   show( @"exists.file.after", [fileManager fileExistsAtPath:@"qdir/file"]);

   [fileManager removeItemAtPath:@"qdir" error:NULL];
   return( 0);
}

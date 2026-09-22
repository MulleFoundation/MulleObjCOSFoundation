#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSFileManager   *fileManager;
   NSArray         *names;
   NSData          *data;

   fileManager = [NSFileManager defaultManager];

   [fileManager removeItemAtPath:@"cm-work" error:NULL];
   [fileManager removeItemAtPath:@"cm-listing" error:NULL];

   [fileManager createDirectoryAtPath:@"cm-work"
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];
   [fileManager createFileAtPath:@"cm-work/a"
                        contents:[NSData dataWithBytes:"hello" length:5]
                      attributes:nil];
   [fileManager createDirectoryAtPath:@"cm-work/sub"
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];
   [fileManager createFileAtPath:@"cm-work/sub/b"
                        contents:[NSData dataWithBytes:"world" length:5]
                      attributes:nil];

   // copy a file
   show( @"copy.file.ok", [fileManager copyItemAtPath:@"cm-work/a"
                                                toPath:@"cm-work/a2"
                                                 error:NULL]);
   show( @"copy.file.same", [fileManager contentsEqualAtPath:@"cm-work/a"
                                                     andPath:@"cm-work/a2"]);

   // copying onto an existing file must fail
   show( @"copy.file.again", [fileManager copyItemAtPath:@"cm-work/a"
                                                  toPath:@"cm-work/a2"
                                                   error:NULL]);

   // move a file
   show( @"move.file.ok", [fileManager moveItemAtPath:@"cm-work/a2"
                                               toPath:@"cm-work/a3"
                                                error:NULL]);
   show( @"move.file.src.gone", [fileManager fileExistsAtPath:@"cm-work/a2"]);
   show( @"move.file.dst", [fileManager fileExistsAtPath:@"cm-work/a3"]);

   // moving onto an existing item must fail
   show( @"move.onto.existing", [fileManager moveItemAtPath:@"cm-work/a3"
                                                     toPath:@"cm-work/sub/b"
                                                      error:NULL]);

   // copy a directory
   show( @"copy.dir.ok", [fileManager copyItemAtPath:@"cm-work/sub"
                                              toPath:@"cm-work/sub2"
                                               error:NULL]);
   show( @"copy.dir.sub", [fileManager fileExistsAtPath:@"cm-work/sub2/b"]);

   // contents
   data = [fileManager contentsAtPath:@"cm-work/a"];
   show( @"contents.file.notnil", data != nil);
   show( @"contents.file.length", [data length] == 5);
   show( @"contents.dir.isnil", [fileManager contentsAtPath:@"cm-work"] == nil);
   show( @"contents.equal.files", [fileManager contentsEqualAtPath:@"cm-work/a"
                                                           andPath:@"cm-work/a3"]);
   show( @"contents.equal.self", [fileManager contentsEqualAtPath:@"cm-work/a"
                                                          andPath:@"cm-work/a"]);
   show( @"contents.equal.dirs", [fileManager contentsEqualAtPath:@"cm-work/sub"
                                                          andPath:@"cm-work/sub2"]);

   // directory contents
   [fileManager createDirectoryAtPath:@"cm-listing"
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];
   [fileManager createFileAtPath:@"cm-listing/x" contents:[NSData data] attributes:nil];
   [fileManager createFileAtPath:@"cm-listing/y" contents:[NSData data] attributes:nil];
   [fileManager createFileAtPath:@"cm-listing/.h" contents:[NSData data] attributes:nil];
   [fileManager createDirectoryAtPath:@"cm-listing/z"
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];

   names = [fileManager directoryContentsAtPath:@"cm-listing"];
   names = [names sortedArrayUsingSelector:@selector( compare:)];
   mulle_printf( "dir.contents=<%s>\n", [[names componentsJoinedByString:@","] UTF8String]);
   show( @"dir.none.isnil", [fileManager directoryContentsAtPath:@"cm-work/nope"] == nil);

   [fileManager removeItemAtPath:@"cm-work" error:NULL];
   [fileManager removeItemAtPath:@"cm-listing" error:NULL];
   return( 0);
}

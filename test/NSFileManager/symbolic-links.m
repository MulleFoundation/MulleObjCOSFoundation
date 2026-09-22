#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSFileManager   *fileManager;
   NSString        *dest;

   fileManager = [NSFileManager defaultManager];

   [fileManager removeItemAtPath:@"symlinks-work" error:NULL];
   [fileManager createDirectoryAtPath:@"symlinks-work"
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];
   [fileManager createFileAtPath:@"symlinks-work/a"
                        contents:[NSData dataWithBytes:"hello" length:5]
                      attributes:nil];

   // create a relative symbolic link
   show( @"create.link", [fileManager createSymbolicLinkAtPath:@"symlinks-work/link"
                                                    pathContent:@"a"]);
   dest = [fileManager pathContentOfSymbolicLinkAtPath:@"symlinks-work/link"];
   mulle_printf( "dest.link=<%s>\n", [dest UTF8String]);
   mulle_printf( "dest.link.len=%d\n", (int) [dest length]);
   show( @"exists.link", [fileManager fileExistsAtPath:@"symlinks-work/link"]);

   // copy the link as a link
   show( @"copy.link", [fileManager copyItemAtPath:@"symlinks-work/link"
                                            toPath:@"symlinks-work/link2"
                                             error:NULL]);
   dest = [fileManager pathContentOfSymbolicLinkAtPath:@"symlinks-work/link2"];
   mulle_printf( "copy.link.dest=<%s>\n", [dest UTF8String]);
   show( @"contents.links.equal", [fileManager contentsEqualAtPath:@"symlinks-work/link"
                                                           andPath:@"symlinks-work/link2"]);
   show( @"contents.link.file.equal", [fileManager contentsEqualAtPath:@"symlinks-work/link"
                                                               andPath:@"symlinks-work/a"]);
   show( @"copy.link.again", [fileManager copyItemAtPath:@"symlinks-work/link"
                                                  toPath:@"symlinks-work/link2"
                                                   error:NULL]);

   // move the link as a link
   show( @"move.link", [fileManager moveItemAtPath:@"symlinks-work/link2"
                                            toPath:@"symlinks-work/link3"
                                             error:NULL]);
   show( @"move.link.src.gone", [fileManager fileExistsAtPath:@"symlinks-work/link2"]);
   dest = [fileManager pathContentOfSymbolicLinkAtPath:@"symlinks-work/link3"];
   mulle_printf( "move.link.dest=<%s>\n", [dest UTF8String]);

   // a dangling link is an item too
   show( @"dangling.create", [fileManager createSymbolicLinkAtPath:@"symlinks-work/dangling"
                                                       pathContent:@"nonexistent"]);
   dest = [fileManager pathContentOfSymbolicLinkAtPath:@"symlinks-work/dangling"];
   mulle_printf( "dangling.dest=<%s>\n", [dest UTF8String]);
   show( @"dangling.exists", [fileManager fileExistsAtPath:@"symlinks-work/dangling"]);
   show( @"copy.dangling", [fileManager copyItemAtPath:@"symlinks-work/dangling"
                                                toPath:@"symlinks-work/dangling2"
                                                 error:NULL]);
   dest = [fileManager pathContentOfSymbolicLinkAtPath:@"symlinks-work/dangling2"];
   mulle_printf( "copy.dangling.dest=<%s>\n", [dest UTF8String]);

   [fileManager removeItemAtPath:@"symlinks-work" error:NULL];
   return( 0);
}

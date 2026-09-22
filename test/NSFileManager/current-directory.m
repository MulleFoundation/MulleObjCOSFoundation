#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSFileManager   *fileManager;
   NSString        *saved;
   NSString        *now;

   fileManager = [NSFileManager defaultManager];

   saved = [fileManager currentDirectoryPath];
   show( @"cwd.notnil", saved != nil);

   [fileManager removeItemAtPath:@"cwdtest" error:NULL];
   [fileManager createDirectoryAtPath:@"cwdtest"
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];

   show( @"chdir.relative", [fileManager changeCurrentDirectoryPath:@"cwdtest"]);
   now = [fileManager currentDirectoryPath];
   show( @"chdir.suffix", [now hasSuffix:@"cwdtest"]);

   show( @"chdir.bad", [fileManager changeCurrentDirectoryPath:@"nope"] == NO);
   show( @"chdir.bad.unchanged", [[fileManager currentDirectoryPath] isEqualToString:now]);

   show( @"chdir.back", [fileManager changeCurrentDirectoryPath:saved]);
   show( @"chdir.back.same", [[fileManager currentDirectoryPath] isEqualToString:saved]);

   [fileManager removeItemAtPath:@"cwdtest" error:NULL];
   return( 0);
}

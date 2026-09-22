#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
#import <MulleObjCOSBaseFoundation/NSBundle-Private.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSFileManager   *fileManager;
   NSBundle        *bundle;
   NSDictionary    *info;
   NSArray         *array;
   NSData          *data;
   NSString        *root;
   NSString        *binDir;
   NSString        *exePath;
   NSString        *resDir;
   NSString        *path;

   fileManager = [NSFileManager defaultManager];

   root    = [[fileManager currentDirectoryPath] stringByAppendingPathComponent:@"bundle-root"];
   binDir  = [root stringByAppendingPathComponent:@"bin"];
   exePath = [binDir stringByAppendingPathComponent:@"bunit"];
   resDir  = [[root stringByAppendingPathComponent:@"share"] stringByAppendingPathComponent:@"bunit"];

   [fileManager removeItemAtPath:root error:NULL];
   [fileManager createDirectoryAtPath:[resDir stringByAppendingPathComponent:@"res"]
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];

   // Posix resource path is "<root>/share/bunit"
   bundle = [NSBundle _bundleWithPath:root
                       executablePath:exePath];
   if( ! bundle)
   {
      mulle_printf( "FAIL: could not create bundle\n");
      return( 1);
   }

   data = [NSData dataWithBytes:"hello" length:5];
   [data writeToFile:[resDir stringByAppendingPathComponent:@"foo.txt"]
          atomically:NO];
   [data writeToFile:[[resDir stringByAppendingPathComponent:@"res"] stringByAppendingPathComponent:@"bar.txt"]
          atomically:NO];

   info = @{ @"NSBundleIdentifier": @"com.test.bunit",
             @"NSBundleDevelopmentRegion": @"en",
             @"TestKey": @"TestValue" };
   [info writeToFile:[resDir stringByAppendingPathComponent:@"Info.plist"]
          atomically:NO];

   show( @"resourcePath", [[bundle resourcePath] hasSuffix:@"share/bunit"]);

   show( @"infoDictionary", [bundle infoDictionary] != nil);
   show( @"objectForKey",
         [[bundle objectForInfoDictionaryKey:@"TestKey"] isEqualToString:@"TestValue"]);
   show( @"bundleIdentifier",
         [[bundle bundleIdentifier] isEqualToString:@"com.test.bunit"]);
   show( @"developmentLocalization",
         [[bundle developmentLocalization] isEqualToString:@"en"]);

   path = [bundle pathForResource:@"foo"
                           ofType:@"txt"];
   show( @"pathForResource",
         path != nil && [[path lastPathComponent] isEqualToString:@"foo.txt"]);

   path = [bundle pathForResource:@"bar"
                           ofType:@"txt"
                      inDirectory:@"res"];
   show( @"pathForResourceInDirectory",
         path != nil && [[path lastPathComponent] isEqualToString:@"bar.txt"]);

   array = [bundle pathsForResourcesOfType:@"txt"
                               inDirectory:nil];
   show( @"pathsForResources", array != nil && [array count] >= 1);

   [fileManager removeItemAtPath:root error:NULL];
   return( 0);
}

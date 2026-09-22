#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
#import <MulleObjCOSBaseFoundation/NSBundle-Private.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSFileManager  *fileManager;
   NSBundle       *bundle;
   NSString       *root;
   NSString       *exeDir;
   NSString       *exePath;
   NSString       *resourcePath;
   NSString       *auxiliary;

   fileManager = [NSFileManager defaultManager];

   root    = [[fileManager currentDirectoryPath] stringByAppendingPathComponent:@"bpath-root"];
   exeDir  = [root stringByAppendingPathComponent:@"bin"];
   exePath = [exeDir stringByAppendingPathComponent:@"bunit"];

   [fileManager removeItemAtPath:root error:NULL];
   [fileManager createDirectoryAtPath:root
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];

   bundle = [NSBundle _bundleWithPath:root
                       executablePath:exePath];
   if( ! bundle)
   {
      mulle_printf( "FAIL: could not create bundle\n");
      return( 1);
   }

   resourcePath = [bundle resourcePath];
   show( @"resource-non-nil", resourcePath != nil);

   show( @"private-frameworks",
         [bundle privateFrameworksPath] != nil
         && [[bundle privateFrameworksPath] hasPrefix:resourcePath]);
   show( @"shared-frameworks",
         [bundle sharedFrameworksPath] != nil
         && [[bundle sharedFrameworksPath] hasPrefix:resourcePath]);
   show( @"shared-support",
         [bundle sharedSupportPath] != nil
         && [[bundle sharedSupportPath] hasPrefix:resourcePath]);

   auxiliary = [bundle pathForAuxiliaryExecutable:@"foo"];
   show( @"auxiliary",
         auxiliary != nil
         && [[auxiliary lastPathComponent] isEqualToString:@"foo"]
         && [auxiliary hasPrefix:exeDir]);

   [fileManager removeItemAtPath:root error:NULL];
   return( 0);
}

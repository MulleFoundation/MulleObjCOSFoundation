#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
#import <MulleObjCOSBaseFoundation/NSBundle-Private.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSBundle       *bundle;
   NSFileManager  *fileManager;
   NSString       *cwd;
   NSString       *path;

   fileManager = [NSFileManager defaultManager];
   cwd         = [fileManager currentDirectoryPath];
   path        = [cwd stringByAppendingPathComponent:@"EmptyBundle.bundle"];

   bundle = [NSBundle bundleWithPath:path];
   if( ! bundle)
   {
      mulle_printf( "FAIL: could not create bundle\n");
      return( 1);
   }

   show( @"builtin-plugins-nil", [bundle builtInPlugInsPath] == nil);
   show( @"path-for-resource-nil", [bundle pathForResource:@"nope"
                                                    ofType:@"plist"] == nil);
   show( @"object-for-info-nil", [bundle objectForInfoDictionaryKey:@"nope"] == nil);
   show( @"os-identifier", [NSBundle _OSIdentifier] != nil);
   show( @"fs-extension-nonsense", [NSBundle isBundleFilesystemExtension:@"zzz"] == NO);

   return( 0);
}

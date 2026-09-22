#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSFileManager  *fileManager;
   NSArray        *paths;
   NSString       *fullUser;
   NSString       *home;
   NSString       *homeForUser;
   NSString       *root;
   NSString       *temporary;
   NSString       *user;
   BOOL           isDirectory;

   fileManager = [NSFileManager defaultManager];

   home      = NSHomeDirectory();
   temporary = NSTemporaryDirectory();
   user      = NSUserName();
   fullUser  = NSFullUserName();
   root      = NSOpenStepRootDirectory();

   show( @"home-non-nil", home != nil && [home length] > 0);
   show( @"home-absolute", [home isAbsolutePath]);
   show( @"home-exists", [fileManager fileExistsAtPath:home
                                           isDirectory:&isDirectory] && isDirectory);

   show( @"temporary-non-nil", temporary != nil && [temporary length] > 0);
   show( @"temporary-exists", [fileManager fileExistsAtPath:temporary
                                                 isDirectory:&isDirectory] && isDirectory);

   show( @"user-non-nil", user != nil && [user length] > 0);
   show( @"full-user-non-nil", fullUser != nil && [fullUser length] > 0);
   show( @"root-non-nil", root != nil && [root length] > 0);

   homeForUser = NSHomeDirectoryForUser(NSUserName());
   show( @"home-for-user-non-nil", homeForUser != nil && [homeForUser length] > 0);

   paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                               NSUserDomainMask,
                                               YES);
   show( @"search-non-nil", paths != nil);
   show( @"search-array", [paths isKindOfClass:[NSArray class]]);

   paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                               NSAllDomainsMask,
                                               YES);
   show( @"search-all-non-nil", paths != nil);

   return( 0);
}

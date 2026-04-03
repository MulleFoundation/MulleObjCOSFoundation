#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int main()
{
   NSString *unixPath = @"/z/home/src/srcO/MulleFoundation/MulleObjCOSFoundation/test/NSBundle";
   NSString *windowsPath = [unixPath mulleWindowsFileSystemString];
   
   mulle_fprintf( stderr, "Unix:    '%s'\n", [unixPath UTF8String]);
   mulle_fprintf( stderr, "Windows: '%s'\n", windowsPath ? [windowsPath UTF8String] : "(nil)");
   mulle_fprintf( stderr, "Length:  %lu\n", windowsPath ? (unsigned long)[windowsPath length] : 0);
   
   return 0;
}

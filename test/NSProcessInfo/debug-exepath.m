#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int main()
{
   NSProcessInfo *info = [NSProcessInfo processInfo];
   NSString *path = [info _executablePath];
   
   mulle_fprintf( stderr, "Executable path: '%s'\n", path ? [path UTF8String] : "(nil)");
   mulle_fprintf( stderr, "Path length: %lu\n", path ? (unsigned long)[path length] : 0);
   
   return 0;
}

#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int main()
{
   NSFileManager *mgr = [NSFileManager defaultManager];
   NSString *path = @"/z/home/src/srcO/MulleFoundation/MulleObjCOSFoundation/test/NSBundle";
   BOOL isDir = NO;
   BOOL exists = [mgr fileExistsAtPath:path isDirectory:&isDir];
   
   mulle_fprintf( stderr, "Path: '%s'\n", [path UTF8String]);
   mulle_fprintf( stderr, "Exists: %s\n", exists ? "YES" : "NO");
   mulle_fprintf( stderr, "IsDirectory: %s\n", isDir ? "YES" : "NO");
   
   return 0;
}

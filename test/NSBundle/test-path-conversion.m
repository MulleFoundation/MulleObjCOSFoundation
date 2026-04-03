#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int main()
{
   NSFileManager *mgr = [NSFileManager defaultManager];
   NSString *unixPath = @"/z/home/src/srcO/MulleFoundation/MulleObjCOSFoundation/test/NSBundle";
   mulle_utf16_t *utf16 = [mgr fileSystemRepresentationUTF16WithPath:unixPath];
   
   mulle_fprintf( stderr, "Unix path: '%s'\n", [unixPath UTF8String]);
   mulle_fprintf( stderr, "UTF16 ptr: %p\n", utf16);
   
   if( utf16)
   {
      // Convert back to NSString to see what we got
      NSString *converted = [[NSString alloc] mulleInitWithUTF16Characters:utf16 length:wcslen((wchar_t*)utf16)];
      mulle_fprintf( stderr, "Converted: '%s'\n", [converted UTF8String]);
      [converted release];
   }
   
   return 0;
}

//
//  Test fileSystemRepresentation conversion
//
//  Tests bidirectional path conversion between Foundation format and Windows format
//  Foundation: /c/path/to/file (lowercase drive, forward slashes)
//  Windows:    C:\path\to\file (uppercase drive, backslashes)
//

#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
#include <stdio.h>


static void test_conversion( char *foundationPath, char *expectedWindowsPath)
{
   NSFileManager   *manager;
   NSString        *path;
   wchar_t         *widePath;
   NSString        *backConverted;
   
   manager = [NSFileManager defaultManager];
   path    = [NSString stringWithCString:foundationPath];
   
   // Convert to Windows format
   widePath = (wchar_t *) [manager fileSystemRepresentationWithPath:path];
   if( ! widePath)
   {
      mulle_printf( "FAIL: %s -> NULL\n", foundationPath);
      return;
   }
   
   // Convert back to Foundation format
   backConverted = [manager stringWithFileSystemRepresentation:(char *) widePath
                                                        length:wcslen( widePath)];
   
   // Free the Windows path
   mulle_allocator_free( MulleObjCInstanceGetAllocator( manager), widePath);
   
   // Check round-trip
   if( ! [backConverted isEqualToString:path])
   {
      mulle_printf( "FAIL: %s -> %s (expected: %s)\n",
              foundationPath, 
              [backConverted UTF8String],
              foundationPath);
   }
   else
   {
      mulle_printf( "OK: %s\n", foundationPath);
   }
}


int main( void)
{
   // Basic paths
   test_conversion( "/c/test", "/c/test");
   test_conversion( "/c/test/file.txt", "/c/test/file.txt");
   test_conversion( "/c/", "/c/");
   test_conversion( "/c/a/b/c/d/e", "/c/a/b/c/d/e");
   
   // Different drives
   test_conversion( "/d/test", "/d/test");
   test_conversion( "/z/wine/path", "/z/wine/path");
   
   // Paths with spaces
   test_conversion( "/c/Program Files", "/c/Program Files");
   test_conversion( "/c/Program Files/test file.txt", "/c/Program Files/test file.txt");
   
   // Paths with special characters
   test_conversion( "/c/test-file", "/c/test-file");
   test_conversion( "/c/test_file", "/c/test_file");
   test_conversion( "/c/test.file.txt", "/c/test.file.txt");
   
   // Paths with umlauts (German)
   test_conversion( "/c/Müller", "/c/Müller");
   test_conversion( "/c/Übung/Ärger/Öl", "/c/Übung/Ärger/Öl");
   test_conversion( "/c/Größe/Maß", "/c/Größe/Maß");
   
   // Paths with accents (French/Spanish)
   test_conversion( "/c/café", "/c/café");
   test_conversion( "/c/résumé", "/c/résumé");
   test_conversion( "/c/niño/año", "/c/niño/año");
   
   // Paths with emoji
   test_conversion( "/c/test😀", "/c/test😀");
   test_conversion( "/c/folder🎉/file🚀.txt", "/c/folder🎉/file🚀.txt");
   test_conversion( "/c/🔥hot🔥", "/c/🔥hot🔥");
   
   // Paths with Asian characters
   test_conversion( "/c/日本語", "/c/日本語");
   test_conversion( "/c/中文/文件", "/c/中文/文件");
   test_conversion( "/c/한글", "/c/한글");
   
   // Paths with Cyrillic
   test_conversion( "/c/Привет", "/c/Привет");
   test_conversion( "/c/Москва/файл", "/c/Москва/файл");
   
   // Edge cases
   test_conversion( "/c/a", "/c/a");
   test_conversion( "/c/.", "/c/.");
   test_conversion( "/c/..", "/c/..");
   test_conversion( "/c/...", "/c/...");
   
   // Long paths
   test_conversion( "/c/very/long/path/with/many/components/to/test/buffer/handling", 
                    "/c/very/long/path/with/many/components/to/test/buffer/handling");
   
   // Mixed everything
   test_conversion( "/c/Müller's café 🎉/résumé_日本語.txt", 
                    "/c/Müller's café 🎉/résumé_日本語.txt");
   
   mulle_printf( "All tests completed\n");
   
   return 0;
}

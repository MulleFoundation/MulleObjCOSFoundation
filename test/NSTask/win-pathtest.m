#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
#include <stdio.h>
#ifdef _WIN32
#include <windows.h>
#endif

int main(void)
{
   NSFileManager *fm;
   NSString      *path;

   fm   = [NSFileManager defaultManager];
   path = @"C:\\windows";

   // Test 1: isReadableFileAtPath (uses mulle_alloca_do + _mulle_utf32_convert_to_utf16)
   mulle_fprintf(stderr, "test1: isReadableFileAtPath...\n");
   {
      BOOL r = [fm isReadableFileAtPath:path];
      mulle_fprintf(stderr, "test1: result=%d\n", (int)r);
   }

   // Test 2: manually do what fileSystemRepresentationWithPath does
   mulle_fprintf(stderr, "test2: manual fileSystemRepresentation...\n");
   {
      NSUInteger pathLen = [path length];
      mulle_fprintf(stderr, "test2a: pathLen=%lu\n", (unsigned long)pathLen);

      wchar_t *result = (wchar_t *)mulle_malloc((pathLen + 1) * sizeof(wchar_t));
      mulle_fprintf(stderr, "test2b: result=%p\n", result);

      // Use alloca directly instead of mulle_alloca_do
      unichar *utf32 = (unichar *)alloca(pathLen * sizeof(unichar));
      mulle_fprintf(stderr, "test2c: utf32=%p\n", utf32);

      [path getCharacters:utf32 range:NSMakeRange(0, pathLen)];
      mulle_fprintf(stderr, "test2d: got chars\n");

      NSUInteger i;
      for(i = 0; i < pathLen; i++)
      {
         unichar c = utf32[i];
         result[i] = (c == '/') ? '\\' : (wchar_t) c;
      }
      result[pathLen] = 0;
      mulle_fprintf(stderr, "test2e: converted, first=%d second=%d\n", (int)result[0], (int)result[1]);

#ifdef _WIN32
      DWORD attrs = GetFileAttributesW(result);
      mulle_fprintf(stderr, "test2f: attrs=%lu\n", (unsigned long)attrs);
#endif
      mulle_free(result);
   }

   // Test 3: now call the actual method
   mulle_fprintf(stderr, "test3: calling actual fileSystemRepresentationWithPath...\n");
   {
      char *rep = [fm fileSystemRepresentationWithPath:path];
      mulle_fprintf(stderr, "test3: rep=%p\n", rep);
      if(rep) mulle_free(rep);
   }

   mulle_fprintf(stderr, "DONE\n");
   return 0;
}

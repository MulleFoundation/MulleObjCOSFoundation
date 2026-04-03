#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int main()
{
   NSString *original = @"Z:\\home\\src\\srcO\\MulleFoundation\\MulleObjCOSFoundation\\test\\NSBundle";
   mulle_utf16_t *utf16;
   NSString *roundtrip;
   
   mulle_fprintf( stderr, "Original:  '%s' (len=%lu)\n", 
                  [original UTF8String], (unsigned long)[original length]);
   
   // Convert to UTF16
   utf16 = [original mulleUTF16String];
   mulle_fprintf( stderr, "UTF16 ptr: %p\n", utf16);
   
   if( utf16)
   {
      size_t utf16_len = wcslen((wchar_t*)utf16);
      mulle_fprintf( stderr, "UTF16 len: %lu (wcslen)\n", (unsigned long)utf16_len);
      
      // Convert back
      roundtrip = [NSString mulleStringWithUTF16String:utf16];
      mulle_fprintf( stderr, "Roundtrip: '%s' (len=%lu)\n",
                     roundtrip ? [roundtrip UTF8String] : "(nil)",
                     roundtrip ? (unsigned long)[roundtrip length] : 0);
      
      // Check if they match
      if( [original isEqualToString:roundtrip])
         mulle_fprintf( stderr, "Result: PASS - strings match\n");
      else
         mulle_fprintf( stderr, "Result: FAIL - strings don't match\n");
   }
   else
   {
      mulle_fprintf( stderr, "Result: FAIL - mulleUTF16String returned NULL\n");
   }
   
   return 0;
}

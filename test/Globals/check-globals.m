#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
#include <stdio.h>

int main( int argc, const char * argv[])
{
   mulle_printf( "=== Global Variables Test ===\n");
   
   // NSString path separators
   mulle_printf( "NSFilePathComponentSeparator: %s\n",
           NSFilePathComponentSeparator ? [NSFilePathComponentSeparator UTF8String] : "NULL");
   mulle_printf( "NSFilePathExtensionSeparator: %s\n",
           NSFilePathExtensionSeparator ? [NSFilePathExtensionSeparator UTF8String] : "NULL");
   
   // NSTask keys
   mulle_printf( "NSTaskExceptionKey: %s\n",
           NSTaskExceptionKey ? [NSTaskExceptionKey UTF8String] : "NULL");
   mulle_printf( "NSTaskTerminationStatusKey: %s\n",
           NSTaskTerminationStatusKey ? [NSTaskTerminationStatusKey UTF8String] : "NULL");
   mulle_printf( "NSTaskStandardOutputDataKey: %s\n",
           NSTaskStandardOutputDataKey ? [NSTaskStandardOutputDataKey UTF8String] : "NULL");
   mulle_printf( "NSTaskStandardOutputStringKey: %s\n",
           NSTaskStandardOutputStringKey ? [NSTaskStandardOutputStringKey UTF8String] : "NULL");
   mulle_printf( "NSTaskStandardErrorDataKey: %s\n",
           NSTaskStandardErrorDataKey ? [NSTaskStandardErrorDataKey UTF8String] : "NULL");
   mulle_printf( "NSTaskStandardErrorStringKey: %s\n",
           NSTaskStandardErrorStringKey ? [NSTaskStandardErrorStringKey UTF8String] : "NULL");
   
   // NSBundle function pointers
   mulle_printf( "NSBundleGetOrRegisterBundleWithPath: %s\n",
           NSBundleGetOrRegisterBundleWithPath ? "exists" : "NULL");
   mulle_printf( "NSBundleDeregisterBundleWithPath: %s\n",
           NSBundleDeregisterBundleWithPath ? "exists" : "NULL");
   
   return( 0);
}

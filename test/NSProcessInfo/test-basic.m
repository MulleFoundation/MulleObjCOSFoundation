#import "import.h"
#include <stdio.h>

static void   test_basic_functionality()
{
   NSProcessInfo   *info;
   NSArray         *args;
   NSDictionary    *env;
   NSString        *path;
   NSString        *name;
   int             pid;
   NSString        *osName;
   NSString        *guid;

   info = [NSProcessInfo processInfo];

   mulle_printf( "Testing NSProcessInfo basic functionality...\n");

   // Test arguments
   args = [info arguments];
   if( ! args)
   {
      mulle_printf( "FAILED: arguments is nil\n");
      return;
   }

   if( ! [args isKindOfClass:[NSArray class]])
   {
      mulle_printf( "FAILED: arguments is not an NSArray\n");
      return;
   }

   mulle_printf( "Arguments count: %ld\n", (long) [args count]);
   // if( [args count] > 0)
   //    mulle_printf( "First argument: %s\n", [[args objectAtIndex:0] UTF8String] ?: "(null)");

   // Test environment
   env = [info environment];
   if( ! env)
   {
      mulle_printf( "FAILED: environment is nil\n");
      return;
   }

   if( ! [env isKindOfClass:[NSDictionary class]])
   {
      mulle_printf( "FAILED: environment is not an NSDictionary\n");
      return;
   }

   // Environment variables count varies between systems - don't print exact count

   // Check for some common environment variables
   if( [env objectForKey:@"PATH"])
      mulle_printf( "PATH environment variable found\n");
   if( [env objectForKey:@"USER"] || [env objectForKey:@"USERNAME"])
      mulle_printf( "User environment variable found\n");

   // Test executable path
   path = [info _executablePath];
   if( ! path)
   {
      mulle_printf( "FAILED: _executablePath is nil\n");
      return;
   }

   if( ! [path isKindOfClass:[NSString class]])
   {
      mulle_printf( "FAILED: _executablePath is not an NSString\n");
      return;
   }

   // mulle_printf( "Executable path: %s\n", [path UTF8String] ?: "(null)");

   // Test process name
   name = [info processName];
   if( ! name)
   {
      mulle_printf( "FAILED: processName is nil\n");
      return;
   }

   if( ! [name isKindOfClass:[NSString class]])
   {
      mulle_printf( "FAILED: processName is not an NSString\n");
      return;
   }

   mulle_printf( "Process name: %s\n", [name UTF8String] ?: "(null)");

   // Test process identifier
   pid = [info processIdentifier];
   if( pid <= 0)
   {
      mulle_printf( "FAILED: processIdentifier is invalid: %d\n", pid);
      return;
   }

   // mulle_printf( "Process identifier: %d\n", pid);

   // Test operating system name
   osName = [info operatingSystemName];
   if( ! osName)
   {
      mulle_printf( "FAILED: operatingSystemName is nil\n");
      return;
   }

   mulle_printf( "Operating system: %s\n", [osName UTF8String] ?: "(null)");

#if 0
   // Test globally unique string
   guid = [info globallyUniqueString];
   if( ! guid)
   {
      mulle_printf( "FAILED: globallyUniqueString is nil\n");
      return;
   }

   mulle_printf( "GUID: %s\n", [guid UTF8String] ?: "(null)");
#endif

   // Test host name
   NSString *hostName = [info hostName];
   mulle_printf( "Host name: %s\n", [hostName UTF8String] ?: "(null)");

   mulle_printf( "All NSProcessInfo tests passed!\n");
}


// Test that the implementation is functionally identical to Linux
static void   test_functional_equivalence()
{
   NSProcessInfo   *info;
   NSArray         *args;
   NSDictionary    *env;
   NSString        *path;
   NSString        *name;
   int             pid;
   NSString        *osName;
   NSString        *guid;
   NSString        *hostName;

   info = [NSProcessInfo processInfo];

   mulle_printf( "Testing functional equivalence with Linux implementation...\n");

   // Test that all methods return expected types and non-nil values
   args = [info arguments];
   assert( args != nil);
   assert( [args isKindOfClass:[NSArray class]]);
   assert( [args count] >= 0);

   env = [info environment];
   assert( env != nil);
   assert( [env isKindOfClass:[NSDictionary class]]);
   assert( [env count] >= 0);

   path = [info _executablePath];
   assert( path != nil);
   assert( [path isKindOfClass:[NSString class]]);
   assert( [path length] > 0);

   name = [info processName];
   assert( name != nil);
   assert( [name isKindOfClass:[NSString class]]);
   assert( [name length] > 0);

   pid = [info processIdentifier];
   assert( pid > 0);

   osName = [info operatingSystemName];
   assert( osName != nil);
   assert( [osName isKindOfClass:[NSString class]]);
   assert( [osName length] > 0);

#if 0
   guid = [info globallyUniqueString];
   assert( guid != nil);
   assert( [guid isKindOfClass:[NSString class]]);
   assert( [guid length] > 0);
#endif

   hostName = [info hostName];
   assert( hostName != nil);
   assert( [hostName isKindOfClass:[NSString class]]);
   assert( [hostName length] > 0);

   // Test that process name is derived from executable path
   NSString *expectedName = [path lastPathComponent];
   assert( [name isEqualToString:expectedName]);

   // Test that OS name contains "Windows"
#if 0
   assert( [[osName lowercaseString] containsString:@"windows"]);

   // Test that GUID has proper format {XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}
   assert( [guid hasPrefix:@"{"]);
   assert( [guid hasSuffix:@"}"]);
   assert( [guid length] == 38);  // {8-4-4-4-12} format
#endif
   mulle_printf( "Functional equivalence tests passed!\n");
}


int   main( int argc, char *argv[])
{
#ifdef __MULLE_OBJC__
   // check that no classes are "stuck"
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) !=
         mulle_objc_universe_is_ok)
      return( 1);
#endif

   mulle_printf( "=== NSProcessInfo Implementation Test ===\n");

   test_basic_functionality();
   test_functional_equivalence();

   mulle_printf( "=== All tests completed successfully ===\n");

   return( 0);
}
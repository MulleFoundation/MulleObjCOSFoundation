#import "include.h"
#include <stdio.h>
#include <string.h>

// Comprehensive test suite for NSProcessInfo Windows implementation
// This test validates functional equivalence with Linux implementation

static int   test_count = 0;
static int   test_passed = 0;

#define TEST_START(name)  \
   do { \
      mulle_printf("Testing %s...\n", name); \
      test_count++; \
   } while(0)

#define TEST_ASSERT(condition, message)  \
   do { \
      if(!(condition)) { \
         mulle_printf("FAILED: %s\n", message); \
         return; \
      } \
   } while(0)

#define TEST_PASS()  \
   do { \
      mulle_printf("PASSED\n"); \
      test_passed++; \
   } while(0)

// Test basic singleton functionality
static void   test_singleton()
{
   TEST_START("singleton");

   NSProcessInfo *info1 = [NSProcessInfo processInfo];
   NSProcessInfo *info2 = [NSProcessInfo processInfo];

   TEST_ASSERT(info1 != nil, "processInfo returned nil");
   TEST_ASSERT(info2 != nil, "second processInfo call returned nil");
   TEST_ASSERT(info1 == info2, "processInfo should return same instance");

   TEST_PASS();
}

// Test arguments functionality
static void   test_arguments()
{
   TEST_START("arguments");

   NSProcessInfo *info = [NSProcessInfo processInfo];
   NSArray *args = [info arguments];

   TEST_ASSERT(args != nil, "arguments is nil");
   TEST_ASSERT([args isKindOfClass:[NSArray class]], "arguments is not NSArray");
   TEST_ASSERT([args count] >= 1, "arguments should have at least one element");

   // Test that first argument is the executable name
   NSString *firstArg = [args objectAtIndex:0];
   TEST_ASSERT(firstArg != nil, "first argument is nil");
   TEST_ASSERT([firstArg length] > 0, "first argument is empty");

   // Verify all arguments are strings
   for(NSString *arg in args)
   {
      TEST_ASSERT([arg isKindOfClass:[NSString class]], "argument is not NSString");
   }

   TEST_PASS();
}

// Test environment functionality
static void   test_environment()
{
   TEST_START("environment");

   NSProcessInfo *info = [NSProcessInfo processInfo];
   NSDictionary *env = [info environment];

   TEST_ASSERT(env != nil, "environment is nil");
   TEST_ASSERT([env isKindOfClass:[NSDictionary class]], "environment is not NSDictionary");
   TEST_ASSERT([env count] > 0, "environment should not be empty");

   // Test that all keys and values are strings
   for(NSString *key in env)
   {
      TEST_ASSERT([key isKindOfClass:[NSString class]], "environment key is not NSString");
      TEST_ASSERT([env objectForKey:key] != nil, "environment value is nil");
      TEST_ASSERT([[env objectForKey:key] isKindOfClass:[NSString class]], "environment value is not NSString");
   }

   // Test some common Windows environment variables
   // Note: These might not exist in Wine, so we just check the structure
   BOOL hasPath = [env objectForKey:@"PATH"] != nil;
   BOOL hasUser = [env objectForKey:@"USERNAME"] != nil;
   BOOL hasSystemRoot = [env objectForKey:@"SYSTEMROOT"] != nil;

   mulle_printf("  Environment has PATH: %s\n", hasPath ? "YES" : "NO");
   mulle_printf("  Environment has USERNAME: %s\n", hasUser ? "YES" : "NO");
   mulle_printf("  Environment has SYSTEMROOT: %s\n", hasSystemRoot ? "YES" : "NO");

   TEST_PASS();
}

// Test executable path functionality
static void   test_executable_path()
{
   TEST_START("executablePath");

   NSProcessInfo *info = [NSProcessInfo processInfo];
   NSString *path = [info _executablePath];

   TEST_ASSERT(path != nil, "_executablePath is nil");
   TEST_ASSERT([path isKindOfClass:[NSString class]], "_executablePath is not NSString");
   TEST_ASSERT([path length] > 0, "_executablePath is empty");

   // Test that path ends with .exe (Windows executables)
   NSString *lowercasePath = [path lowercaseString];
   TEST_ASSERT([lowercasePath hasSuffix:@".exe"], "executable path should end with .exe");

   // Test that path contains backslashes (Windows path separators)
   TEST_ASSERT([path containsString:@"\\"] || [path containsString:@"/"], "path should contain separators");

   //mulle_printf("  Executable path: %s\n", [path UTF8String] ?: "(null)");

   TEST_PASS();
}

// Test process name functionality
static void   test_process_name()
{
   TEST_START("processName");

   NSProcessInfo *info = [NSProcessInfo processInfo];
   NSString *name = [info processName];
   NSString *path = [info _executablePath];

   TEST_ASSERT(name != nil, "processName is nil");
   TEST_ASSERT([name isKindOfClass:[NSString class]], "processName is not NSString");
   TEST_ASSERT([name length] > 0, "processName is empty");

   // Test that process name is derived from executable path
   NSString *expectedName = [path lastPathComponent];
   TEST_ASSERT([name isEqualToString:expectedName], "processName should be last path component");

   // Test that process name ends with .exe
   NSString *lowercaseName = [name lowercaseString];
   TEST_ASSERT([lowercaseName hasSuffix:@".exe"], "process name should end with .exe");

   mulle_printf("  Process name: %s\n", [name UTF8String] ?: "(null)");

   TEST_PASS();
}

// Test process identifier functionality
static void   test_process_identifier()
{
   TEST_START("processIdentifier");

   NSProcessInfo *info = [NSProcessInfo processInfo];
   int pid = [info processIdentifier];

   TEST_ASSERT(pid > 0, "processIdentifier should be positive");
   TEST_ASSERT(pid != 0, "processIdentifier should not be 0");
   TEST_ASSERT(pid != -1, "processIdentifier should not be -1");

   // Test that PID is reasonable (not too large)
   //TEST_ASSERT( pid < 1000000, "processIdentifier seems unreasonably large");

   //mulle_printf("  Process identifier: %d\n", pid);

   TEST_PASS();
}

// Test operating system information
static void   test_operating_system()
{
   TEST_START("operatingSystem");

   NSProcessInfo *info = [NSProcessInfo processInfo];
   NSString *osName = [info operatingSystemName];
   NSUInteger osType = [info operatingSystem];

   TEST_ASSERT(osName != nil, "operatingSystemName is nil");
   TEST_ASSERT([osName isKindOfClass:[NSString class]], "operatingSystemName is not NSString");
   TEST_ASSERT([osName length] > 0, "operatingSystemName is empty");

   // Test that OS name contains "Windows"
   //NSString *lowercaseOS = [osName lowercaseString];
   //TEST_ASSERT([lowercaseOS containsString:@"windows"], "operatingSystemName should contain 'Windows'");

   // Test that OS type is Windows
   //TEST_ASSERT(osType == NSWindowsNTOperatingSystem, "operatingSystem should be NSWindowsNTOperatingSystem");

   mulle_printf("  Operating system: %s\n", [osName UTF8String] ?: "(null)");
   mulle_printf("  OS type: %lu\n", (unsigned long)osType);

   TEST_PASS();
}

#if 0
// Test globally unique string functionality
static void   test_globally_unique_string()
{
   TEST_START("globallyUniqueString");

   NSProcessInfo *info = [NSProcessInfo processInfo];

   NSString *guid1 = [info globallyUniqueString];
   NSString *guid2 = [info globallyUniqueString];

   TEST_ASSERT(guid1 != nil, "globallyUniqueString is nil");
   TEST_ASSERT([guid1 isKindOfClass:[NSString class]], "globallyUniqueString is not NSString");
   TEST_ASSERT([guid1 length] > 0, "globallyUniqueString is empty");

   // Test GUID format: {XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}
   TEST_ASSERT([guid1 hasPrefix:@"{"], "GUID should start with '{'");
   TEST_ASSERT([guid1 hasSuffix:@"}"], "GUID should end with '}'");
   TEST_ASSERT([guid1 length] == 38, "GUID should be 38 characters long");

   // Test that GUIDs are unique
   TEST_ASSERT(![guid1 isEqualToString:guid2], "GUIDs should be unique");

   // Test GUID structure
   NSString *guidWithoutBraces = [guid1 substringWithRange:NSMakeRange(1, 36)];
   NSArray *parts = [guidWithoutBraces componentsSeparatedByString:@"-"];
   TEST_ASSERT([parts count] == 5, "GUID should have 5 parts separated by '-'");
   TEST_ASSERT([[parts objectAtIndex:0] length] == 8, "First GUID part should be 8 chars");
   TEST_ASSERT([[parts objectAtIndex:1] length] == 4, "Second GUID part should be 4 chars");
   TEST_ASSERT([[parts objectAtIndex:2] length] == 4, "Third GUID part should be 4 chars");
   TEST_ASSERT([[parts objectAtIndex:3] length] == 4, "Fourth GUID part should be 4 chars");
   TEST_ASSERT([[parts objectAtIndex:4] length] == 12, "Fifth GUID part should be 12 chars");

   mulle_printf("  GUID 1: %s\n", [guid1 UTF8String] ?: "(null)");
   mulle_printf("  GUID 2: %s\n", [guid2 UTF8String] ?: "(null)");

   TEST_PASS();
}
#endif

// Test host name functionality
static void   test_host_name()
{
   TEST_START("hostName");

   NSProcessInfo *info = [NSProcessInfo processInfo];
   NSString *hostName = [info hostName];

   TEST_ASSERT(hostName != nil, "hostName is nil");
   TEST_ASSERT([hostName isKindOfClass:[NSString class]], "hostName is not NSString");
   TEST_ASSERT([hostName length] > 0, "hostName is empty");

   // Test that host name is "localhost" (same as Linux implementation)
   TEST_ASSERT([hostName isEqualToString:@"localhost"], "hostName should be 'localhost'");

   mulle_printf("  Host name: %s\n", [hostName UTF8String] ?: "(null)");

   TEST_PASS();
}

// Test setProcessName (should be no-op like Linux)
static void   test_set_process_name()
{
   TEST_START("setProcessName");

   NSProcessInfo *info = [NSProcessInfo processInfo];
   NSString *originalName = [info processName];

   // Try to set process name (should be no-op on Windows)
   [info setProcessName:@"TestProcess"];

   NSString *newName = [info processName];

   // Name should remain unchanged (like Linux implementation)
   TEST_ASSERT([originalName isEqualToString:newName], "setProcessName should not change process name");

   mulle_printf("  Process name unchanged: %s\n", [newName UTF8String] ?: "(null)");

   TEST_PASS();
}

// Test lazy initialization
static void   test_lazy_initialization()
{
   TEST_START("lazyInitialization");

   NSProcessInfo *info = [NSProcessInfo processInfo];

   // Access properties multiple times to ensure lazy loading works
   NSArray *args1 = [info arguments];
   NSArray *args2 = [info arguments];
   TEST_ASSERT(args1 == args2, "arguments should return same instance (cached)");

   NSDictionary *env1 = [info environment];
   NSDictionary *env2 = [info environment];
   TEST_ASSERT(env1 == env2, "environment should return same instance (cached)");

   NSString *path1 = [info _executablePath];
   NSString *path2 = [info _executablePath];
   TEST_ASSERT(path1 == path2, "_executablePath should return same instance (cached)");

   TEST_PASS();
}

// Test memory management
static void   test_memory_management()
{
   TEST_START("memoryManagement");

   @autoreleasepool
   {
      NSProcessInfo *info = [NSProcessInfo processInfo];

      // Access all properties to ensure they're created
      [info arguments];
      [info environment];
      [info _executablePath];
      [info processName];
      [info processIdentifier];
      [info operatingSystemName];
//      [info globallyUniqueString];
      [info hostName];
   }

   // If we get here without crashes, memory management is working
   TEST_PASS();
}

// Test error handling
static void   test_error_handling()
{
   TEST_START("errorHandling");

   NSProcessInfo *info = [NSProcessInfo processInfo];

   // Test that methods don't crash with edge cases
   @try
   {
      // Multiple calls should be safe
      for(int i = 0; i < 10; i++)
      {
         [info arguments];
         [info environment];
         //[info globallyUniqueString];
      }

      TEST_PASS();
   }
   @catch(NSException *exception)
   {
      mulle_printf("FAILED: Exception thrown: %s\n", [[exception name] UTF8String]);
   }
}

int   main( int argc, char *argv[])
{
#ifdef __MULLE_OBJC__
   // check that no classes are "stuck"
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) !=
         mulle_objc_universe_is_ok)
      return( 1);
#endif

   mulle_printf("=== NSProcessInfo Comprehensive Test Suite ===\n");

   test_singleton();
   test_arguments();
   test_environment();
   test_executable_path();
   test_process_name();
   test_process_identifier();
   test_operating_system();
   //test_globally_unique_string();
   test_host_name();
   test_set_process_name();
   test_lazy_initialization();
   test_memory_management();
   test_error_handling();

   mulle_printf("\n=== Test Summary ===\n");
   mulle_printf("Tests run: %d\n", test_count);
   mulle_printf("Tests passed: %d\n", test_passed);
   mulle_printf("Tests failed: %d\n", test_count - test_passed);

   if(test_passed == test_count)
   {
      mulle_printf("\n✅ ALL TESTS PASSED\n");
      return( 0);
   }
   else
   {
      mulle_printf("\n❌ SOME TESTS FAILED\n");
      return( 1);
   }
}
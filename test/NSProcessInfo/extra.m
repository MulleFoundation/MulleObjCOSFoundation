#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSProcessInfo   *info;
   NSDictionary    *environment;
   NSString        *name;
   NSString        *name2;
   NSString        *osVersion;
   NSString        *unique1;
   NSString        *unique2;

   info = [NSProcessInfo processInfo];

   osVersion = [info operatingSystemVersionString];
   show( @"os-version-non-nil", osVersion != nil && [osVersion length] > 0);

   unique1 = [info globallyUniqueString];
   unique2 = [info globallyUniqueString];
   show( @"globally-unique-non-nil", unique1 != nil && [unique1 length] > 0);
   show( @"globally-unique-unique", ! [unique1 isEqualToString:unique2]);

   show( @"pid-positive", [info processIdentifier] > 0);
   show( @"host-non-nil", [info hostName] != nil);

   // setProcessName: is a no-op on these platforms
   name = [info processName];
   [info setProcessName:@"mulle-test-name"];
   name2 = [info processName];
   show( @"process-name-stable", [name isEqualToString:name2]);

   // environment mutation
   [info environment];
   [info mulleSetEnvironmentValue:@"abc"
                           forKey:@"MULLE_TEST_VAR"];
   environment = [info environment];
   show( @"environment-set",
         [[environment objectForKey:@"MULLE_TEST_VAR"] isEqualToString:@"abc"]);

   [info mulleSetEnvironmentValue:nil
                           forKey:@"MULLE_TEST_VAR"];
   environment = [info environment];
   show( @"environment-unset", [environment objectForKey:@"MULLE_TEST_VAR"] == nil);

   return( 0);
}

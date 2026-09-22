#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSUserDefaults   *defaults;
   NSArray          *array;
   NSData           *data;

   defaults = [NSUserDefaults standardUserDefaults];

   [defaults removeObjectForKey:@"s"];
   [defaults removeObjectForKey:@"i"];

   [defaults setObject:@"hello"
                forKey:@"s"];
   show( @"object", [[defaults objectForKey:@"s"] isEqualToString:@"hello"]);
   show( @"string", [[defaults stringForKey:@"s"] isEqualToString:@"hello"]);

   [defaults setInteger:12345
                 forKey:@"i"];
   show( @"integer", [defaults integerForKey:@"i"] == 12345);
   show( @"double-int", [defaults doubleForKey:@"i"] == 12345.0);
   show( @"string-on-number-nil", [defaults stringForKey:@"i"] == nil);

   [defaults setBool:YES
              forKey:@"b"];
   show( @"bool-yes", [defaults boolForKey:@"b"]);
   [defaults setBool:NO
              forKey:@"b"];
   show( @"bool-no", ! [defaults boolForKey:@"b"]);

   [defaults setDouble:1.25
                forKey:@"d"];
   show( @"double", [defaults doubleForKey:@"d"] == 1.25);
   show( @"float", [defaults floatForKey:@"d"] == 1.25);

   [defaults setObject:@[ @"a", @"b" ]
                forKey:@"arr"];
   array = [defaults arrayForKey:@"arr"];
   show( @"array", [array count] == 2);
   show( @"string-array", [[defaults stringArrayForKey:@"arr"] count] == 2);

   [defaults setObject:@[ @"a", @1 ]
                forKey:@"mix"];
   show( @"string-array-mixed-nil", [defaults stringArrayForKey:@"mix"] == nil);

   [defaults setObject:@{ @"k": @"v" }
                forKey:@"dict"];
   show( @"dictionary", [[defaults dictionaryForKey:@"dict"] count] == 1);
   show( @"array-on-dict-nil", [defaults arrayForKey:@"dict"] == nil);

   data = [NSData dataWithBytes:"ab"
                          length:2];
   [defaults setObject:data
                forKey:@"data"];
   show( @"data", [[defaults dataForKey:@"data"] length] == 2);

   show( @"missing-object-nil", [defaults objectForKey:@"nope"] == nil);
   show( @"missing-string-nil", [defaults stringForKey:@"nope"] == nil);
   show( @"missing-integer", [defaults integerForKey:@"nope"] == 0);
   show( @"missing-bool", [defaults boolForKey:@"nope"] == NO);

   [defaults removeObjectForKey:@"s"];
   show( @"removed", [defaults objectForKey:@"s"] == nil);

   return( 0);
}

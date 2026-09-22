#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSUserDefaults   *defaults;
   NSDictionary     *representation;

   defaults = [NSUserDefaults standardUserDefaults];

   [defaults registerDefaults:@{ @"ka"     : @"reg",
                                 @"kb"     : @"reg",
                                 @"onlyreg": @"r" }];
   [defaults setObject:@"app"
                forKey:@"ka"];

   show( @"object-app", [[defaults objectForKey:@"ka"] isEqualToString:@"app"]);
   show( @"object-reg", [[defaults objectForKey:@"kb"] isEqualToString:@"reg"]);
   show( @"object-onlyreg", [[defaults objectForKey:@"onlyreg"] isEqualToString:@"r"]);

   representation = [defaults dictionaryRepresentation];
   show( @"representation-app",
         [[representation objectForKey:@"ka"] isEqualToString:@"app"]);
   show( @"representation-reg",
         [[representation objectForKey:@"kb"] isEqualToString:@"reg"]);
   show( @"representation-onlyreg",
         [[representation objectForKey:@"onlyreg"] isEqualToString:@"r"]);

   return( 0);
}

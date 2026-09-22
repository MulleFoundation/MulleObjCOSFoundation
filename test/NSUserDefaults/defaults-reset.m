#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSUserDefaults   *defaults;

   defaults = [NSUserDefaults standardUserDefaults];

   [defaults registerDefaults:@{ @"rd": @"reg" }];
   [defaults setObject:@"x"
                forKey:@"ra"];

   show( @"before-app", [[defaults objectForKey:@"ra"] isEqualToString:@"x"]);
   show( @"before-reg", [[defaults objectForKey:@"rd"] isEqualToString:@"reg"]);

   [NSUserDefaults resetStandardUserDefaults];

   show( @"after-app", [defaults objectForKey:@"ra"] == nil);
   show( @"after-reg", [defaults objectForKey:@"rd"] == nil);

   return( 0);
}

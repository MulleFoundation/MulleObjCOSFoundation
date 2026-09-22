#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSUserDefaults   *defaults;
   NSInteger        big;

   defaults = [NSUserDefaults standardUserDefaults];

   big = ((NSInteger) 1 << 53) + 1;

   [defaults setInteger:big
                 forKey:@"big"];
   show( @"big-exact", [defaults integerForKey:@"big"] == big);

   [defaults setInteger:-42
                 forKey:@"neg"];
   show( @"negative", [defaults integerForKey:@"neg"] == -42);

   return( 0);
}

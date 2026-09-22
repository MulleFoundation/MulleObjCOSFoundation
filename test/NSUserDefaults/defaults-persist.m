#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSUserDefaults   *defaults;
   NSUserDefaults   *reloaded;
   NSUserDefaults   *cleaned;
   BOOL             saved;

   defaults = [NSUserDefaults standardUserDefaults];

   [defaults removeObjectForKey:@"pk"];
   [defaults synchronize];

   [defaults setObject:@"persisted"
                forKey:@"pk"];
   saved = [defaults synchronize];

   reloaded = [[NSUserDefaults alloc] init];
   show( @"saved", saved);
   show( @"loaded", [[reloaded objectForKey:@"pk"] isEqualToString:@"persisted"]);
   [reloaded release];

   // cleanup, so the test is repeatable
   [defaults removeObjectForKey:@"pk"];
   [defaults synchronize];

   cleaned = [[NSUserDefaults alloc] init];
   show( @"cleaned", [cleaned objectForKey:@"pk"] == nil);
   [cleaned release];

   return( 0);
}

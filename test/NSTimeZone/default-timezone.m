#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int main()
{
   NSTimeZone  *defaultTZ;
   NSTimeZone  *systemTZ;
   NSInteger   seconds;
   
   defaultTZ = [NSTimeZone defaultTimeZone];
   systemTZ  = [NSTimeZone systemTimeZone];
   
   mulle_printf("Default timezone: %s\n", [[defaultTZ name] UTF8String]);
   mulle_printf("Default abbreviation: %s\n", [[defaultTZ abbreviation] UTF8String]);
   
   seconds = [defaultTZ secondsFromGMT];
   mulle_printf("Default seconds from GMT: %ld\n", (long)seconds);
   
   mulle_printf("\n");
   mulle_printf("System timezone: %s\n", [[systemTZ name] UTF8String]);
   mulle_printf("System abbreviation: %s\n", [[systemTZ abbreviation] UTF8String]);
   
   seconds = [systemTZ secondsFromGMT];
   mulle_printf("System seconds from GMT: %ld\n", (long)seconds);
   
   // Check if they're GMT/UTC
   if( seconds == 0)
   {
      mulle_printf("\nPASS: Default timezone is GMT/UTC\n");
      return 0;
   }
   else
   {
      mulle_printf("\nFAIL: Default timezone is NOT GMT/UTC (offset: %ld seconds)\n", (long)seconds);
      return 1;
   }
}

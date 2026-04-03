#import "import-private.h"

#include "Functions/mulle-windows-tm.h"

#include <time.h>


@implementation NSDate( Windows)


- (instancetype) _initWithTM:(struct tm *) tm
                 nanoseconds:(unsigned long long) nanoseconds
                    timeZone:(NSTimeZone *) tz
{
   NSTimeInterval    since1970;

   NSParameterAssert( nanoseconds < 1000000000);

   since1970  = mulle_windows_tm_get_time( tm);
   since1970 += nanoseconds / 1000000000.0;
   since1970 -= [tz mulleSecondsFromGMTForTimeIntervalSince1970:since1970];

   return( [self initWithTimeIntervalSince1970:since1970]);
}

@end

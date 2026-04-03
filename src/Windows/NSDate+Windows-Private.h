//
//  NSDate+Windows-Private.h
//  MulleObjCOSFoundation
//
//  Created by Nat! on 05.02.26
//  Copyright © 2026 Mulle kybernetiK. All rights reserved.
//

#include <time.h>


NSTimeInterval   _NSTimeIntervalNow( void);


@interface NSDate (Windows)

- (instancetype) _initWithTM:(struct tm *) tm
                 nanoseconds:(unsigned long long) nanoseconds
                    timeZone:(NSTimeZone *) tz;

@end

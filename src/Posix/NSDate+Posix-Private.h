//
//  NSDate+Posix-Private.h
//  MulleObjCOSFoundation
//
//  Created by Nat! on 06.04.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#include <sys/time.h>


NSTimeInterval   _NSTimeIntervalNow( void);


@interface NSDate (Posix)

- (instancetype) _initWithTM:(struct tm *) tm
                 nanoseconds:(unsigned long long) nanoseconds
                    timeZone:(NSTimeZone *) tz;
- (struct timeval) _timevalForSelect;

@end

//
//  NSTimeZone+Windows-Private.h
//  MulleObjCOSFoundation
//
//  Created by Nat! on 05.02.26
//  Copyright © 2026 Mulle kybernetiK. All rights reserved.
//

@interface NSTimeZone( Windows_Private)

- (NSTimeInterval) _timeIntervalSince1970ForTM:(struct tm *) tm;
- (NSInteger) mulleSecondsFromGMTForTimeIntervalSince1970:(NSTimeInterval) interval;

@end

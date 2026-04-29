//
//  NSDate+Posix-Private.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.06.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

@interface NSDate( OSBase_PrivateFuture) < MulleObjCFuture>

- (size_t) _printDate:(NSDate *) date
               buffer:(char *) buf
               length:(size_t) len
        formatUTF8String:(char *) c_format
               locale:(NSLocale *) locale
             timeZone:(NSTimeZone *) timeZone;

@end

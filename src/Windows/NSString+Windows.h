/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSString+Windows.h is a part of MulleObjCOSFoundation
 *
 *  Copyright (C) 2024 Mulle kybernetiK.
 *  All rights reserved.
 *
 */

#import "import.h"

#import <MulleObjCValueFoundation/NSString.h>


@interface NSString( Windows)

- (NSString *) mulleUnixFileSystemString;
- (NSString *) mulleWindowsFileSystemString;

@end

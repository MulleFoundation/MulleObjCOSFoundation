/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSFileManager+Windows.h is a part of MulleObjCOSFoundation
 *
 *  Copyright (C) 2024 Mulle kybernetiK.
 *  All rights reserved.
 *
 */

#import "import.h"

#import <MulleObjCOSBaseFoundation/NSFileManager.h>


@interface NSFileManager( Windows)

- (mulle_utf16_t *) fileSystemRepresentationUTF16WithPath:(NSString *) path;

- (NSString *) stringWithFileSystemRepresentationUTF16:(mulle_utf16_t *) s_utf16
                                                length:(NSUInteger) len;

@end

//
//  NSLog.h (Windows)
//  MulleObjCOSFoundation
//
//  Created by Nat! on 23.01.26
//  Copyright © 2026 Mulle kybernetiK. All rights reserved.
//
#import "import.h"



//
// MEMO: don't move to OSBase, will give horrible problems on windows
//       as the linker can't deal with future globals, (you can't call
//       NSLog from OSBase...)
//
MULLE_OBJC_WINDOWS_FOUNDATION_GLOBAL
void   NSLog( NSString *format, ...);


MULLE_OBJC_WINDOWS_FOUNDATION_GLOBAL
void   NSLogv( NSString *format, va_list args);


MULLE_OBJC_WINDOWS_FOUNDATION_GLOBAL
void   NSLogArguments( NSString *format, mulle_vararg_list args);

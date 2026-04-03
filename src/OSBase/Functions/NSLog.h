/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSLog.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "import.h"

//
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL
void   NSLog( NSString *format, ...);

MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL
void   NSLogv( NSString *format, va_list args);

// mulle addition, NSLogv is a clang builtin...NSLogv
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL
void   NSLogArguments( NSString *format, mulle_vararg_list args);

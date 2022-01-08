//
//  MulleObjCPosixFoundation.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 05.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//
#define MULLE_OBJC_OS_FOUNDATION_VERSION   ((0 << 20) | (20 << 8) | 0)


#import "import.h"


// BSD, OS X, Linux

// want to have alloca available from now on

#ifdef __APPLE__
# include <alloca.h>
#else
# ifdef __linux__
#  include <alloca.h>
# else
#  ifdef __unix__
#   include <stdlib.h> // has alloca
#  endif
# endif
#endif


#ifdef __has_include
# if __has_include( "_MulleObjCOSFoundation-versioncheck.h")
#  include "_MulleObjCOSFoundation-versioncheck.h"
# endif
#endif

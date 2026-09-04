//
//  NSDateFormatter+BSD.m
//  MulleObjCOSFoundation
//
//  Copyright (c) 2017 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
#import "import-private.h"

// other files in this library
#include "mulle-bsd-tm.h"

// other libraries of MulleObjCPosixFoundation
#import <MulleObjCOSBaseFoundation/NSDate+OSBase-Private.h>
#import <MulleObjCPosixFoundation/NSLocale+Posix-Private.h>
#include <MulleObjCStandardFoundation/mulle-mini-tm.h>
#include <MulleObjCPosixFoundation/mulle-posix-tm.h>

// std-c and dependencies
#include <time.h>
#include <xlocale.h>


@implementation NSDateFormatter( BSD)

- (size_t) _printTM:(struct tm *) tm
             buffer:(char *) buf
             length:(size_t) len
      formatUTF8String:(char *) c_format
             locale:(NSLocale *) locale
{
   locale_t    xlocale;

   NSParameterAssert( tm);
   NSParameterAssert( c_format);
   NSParameterAssert( [locale isKindOfClass:[NSLocale class]]);

   xlocale  = [locale xlocale];
   if( xlocale)
      len = strftime_l( buf, len, c_format, tm, xlocale);
   else
      len = strftime( buf, len, c_format, tm);
   return( len);
}

@end

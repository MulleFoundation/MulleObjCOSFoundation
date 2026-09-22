//
//  bundle-localized.m
//  MulleObjCOSFoundation
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
//  All rights reserved.
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
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

#include <stdio.h>


int   main( int argc, const char * argv[])
{
   NSBundle       *bundle;
   NSFileManager  *manager;
   NSString       *cwd;
   NSString       *path;
   NSString       *s;
   int            missingKey;
   int            nilKeyValue;
   int            nilKeyNilValue;
   int            missingKeyDefault;
   int            emptyTable;

   manager = [NSFileManager defaultManager];
   cwd     = [manager currentDirectoryPath];
   path    = [cwd stringByAppendingPathComponent:@"EmptyBundle.bundle"];

   bundle = [NSBundle bundleWithPath:path];
   if( ! bundle)
   {
      mulle_printf( "FAIL: could not create bundle\n");
      return( 1);
   }

   s = [bundle localizedStringForKey:@"MISSING_KEY" value:nil table:nil];
   missingKey = [s isEqualToString:@"MISSING_KEY"];

   s = [bundle localizedStringForKey:nil value:@"DEFAULT" table:nil];
   nilKeyValue = [s isEqualToString:@"DEFAULT"];

   s = [bundle localizedStringForKey:nil value:nil table:nil];
   nilKeyNilValue = [s isEqualToString:@""];

   s = [bundle localizedStringForKey:@"MISSING_KEY" value:@"FALLBACK" table:@"NoSuchTable"];
   missingKeyDefault = [s isEqualToString:@"MISSING_KEY"];

   s = [bundle localizedStringForKey:@"MISSING_KEY" value:nil table:@""];
   emptyTable = [s isEqualToString:@"MISSING_KEY"];

   mulle_printf( "missing-key=%d\n", missingKey ? 1 : 0);
   mulle_printf( "nil-key-value=%d\n", nilKeyValue ? 1 : 0);
   mulle_printf( "nil-key-nil-value=%d\n", nilKeyNilValue ? 1 : 0);
   mulle_printf( "missing-key-default=%d\n", missingKeyDefault ? 1 : 0);
   mulle_printf( "empty-table=%d\n", emptyTable ? 1 : 0);
   return( 0);
}

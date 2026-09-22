//
//  bundle-address.m
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
#import <MulleObjCOSBaseFoundation/NSBundle-Private.h>

#include <stdio.h>


int   main( int argc, const char * argv[])
{
   NSBundle                         *bundle;
   NSFileManager                    *manager;
   NSString                         *cwd;
   NSString                         *path;
   struct _MulleObjCSharedLibrary   info;
   char                             *base;
   int                              after;
   int                              atEnd;
   int                              atStart;
   int                              before;
   int                              inside;

   manager = [NSFileManager defaultManager];
   cwd     = [manager currentDirectoryPath];
   path    = [cwd stringByAppendingPathComponent:@"EmptyBundle.bundle"];

   base = (char *) 0x10000000;

   info.path   = @"libEmptyBundle.so";
   info.start  = base;
   info.end    = base + 0x1000;
   info.handle = NULL;

   bundle = [[[NSBundle alloc] _mulleInitWithPath:path
                                sharedLibraryInfo:&info] autorelease];
   if( ! bundle)
   {
      mulle_printf( "FAIL: could not create bundle\n");
      return( 1);
   }

   atStart = [bundle mulleContainsAddress:base];
   inside  = [bundle mulleContainsAddress:base + 0x500];
   before  = [bundle mulleContainsAddress:base - 0x500];
   after   = [bundle mulleContainsAddress:base + 0x1500];
   atEnd   = [bundle mulleContainsAddress:base + 0x1000];

   mulle_printf( "at-start=%d\n", atStart);
   mulle_printf( "inside=%d\n", inside);
   mulle_printf( "before=%d\n", before);
   mulle_printf( "after=%d\n", after);
   mulle_printf( "at-end=%d\n", atEnd);
   return( 0);
}

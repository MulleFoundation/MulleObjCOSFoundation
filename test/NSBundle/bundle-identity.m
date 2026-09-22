//
//  bundle-identity.m
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
   NSBundle       *bundle1;
   NSBundle       *bundle2;
   NSBundle       *mainBundle;
   NSArray        *bundles;
   NSFileManager  *manager;
   NSString       *cwd;
   NSString       *path;
   int            frameworks;
   int            inAllBundles;
   int            mainInBundles;
   int            same;

   manager = [NSFileManager defaultManager];
   cwd     = [manager currentDirectoryPath];
   path    = [cwd stringByAppendingPathComponent:@"EmptyBundle.bundle"];

   bundle1 = [NSBundle bundleWithPath:path];
   bundle2 = [NSBundle bundleWithPath:path];
   if( ! bundle1)
   {
      mulle_printf( "FAIL: could not create bundle\n");
      return( 1);
   }

   same          = (bundle1 == bundle2);
   bundles       = [NSBundle allBundles];
   inAllBundles  = [bundles containsObject:bundle1];
   mainBundle    = [NSBundle mainBundle];
   mainInBundles = [bundles containsObject:mainBundle];
   frameworks    = (int) [[NSBundle allFrameworks] count];

   mulle_printf( "same=%d\n", same ? 1 : 0);
   mulle_printf( "in-all-bundles=%d\n", inAllBundles ? 1 : 0);
   mulle_printf( "main-in-bundles=%d\n", mainInBundles ? 1 : 0);
   mulle_printf( "frameworks=%d\n", frameworks);
   return( 0);
}

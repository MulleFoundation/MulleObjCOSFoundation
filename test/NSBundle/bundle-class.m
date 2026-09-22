//
//  bundle-class.m
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
   NSBundle       *bundle;
   NSFileManager  *manager;
   NSString       *cwd;
   NSString       *exePath;
   NSString       *osIdentifier;
   NSString       *path;
   int            bundlePathExists;
   int            classNamed;
   int            mainBundlePathExists;
   int            missingClass;
   int            nilClass;
   int            osIdentifierNonNil;
   int            principalClassNil;

   manager = [NSFileManager defaultManager];
   cwd     = [manager currentDirectoryPath];
   path    = [cwd stringByAppendingPathComponent:@"EmptyBundle.bundle"];

   bundle = [NSBundle bundleWithPath:path];
   if( ! bundle)
   {
      mulle_printf( "FAIL: could not create bundle\n");
      return( 1);
   }

   exePath = [NSString stringWithUTF8String:(char *) argv[ 0]];

   classNamed          = ([bundle classNamed:@"NSString"] == [NSString class]);
   missingClass        = ([bundle classNamed:@"NoSuchClass_xyz"] == nil);
   nilClass            = ([bundle classNamed:nil] == nil);
   principalClassNil   = ([bundle principalClass] == nil);

   osIdentifier        = [NSBundle _OSIdentifier];
   osIdentifierNonNil  = (osIdentifier != nil && [osIdentifier length] > 0);

   path                = [NSBundle _mainBundlePathForExecutablePath:exePath];
   mainBundlePathExists = (path != nil && [manager fileExistsAtPath:path]);

   path                = [NSBundle _bundlePathForExecutablePath:exePath];
   bundlePathExists    = (path != nil && [manager fileExistsAtPath:path]);

   mulle_printf( "class-named=%d\n", classNamed ? 1 : 0);
   mulle_printf( "missing-class=%d\n", missingClass ? 1 : 0);
   mulle_printf( "nil-class=%d\n", nilClass ? 1 : 0);
   mulle_printf( "principal-class-nil=%d\n", principalClassNil ? 1 : 0);
   mulle_printf( "os-identifier=%d\n", osIdentifierNonNil ? 1 : 0);
   mulle_printf( "main-bundle-path-exists=%d\n", mainBundlePathExists ? 1 : 0);
   mulle_printf( "bundle-path-exists=%d\n", bundlePathExists ? 1 : 0);
   return( 0);
}

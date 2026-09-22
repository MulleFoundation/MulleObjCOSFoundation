//
//  bundle-basics.m
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
   NSBundle       *mainBundle;
   NSBundle       *byIdentifier;
   NSFileManager  *manager;
   NSString       *cwd;
   NSString       *path;
   int            classNamed;
   int            falseIdentifier;
   int            loaded;
   int            localizedInfo;
   int            localizations;
   int            mainIdentifier;
   int            nilClass;
   int            nilIdentifier;
   int            preferred;
   int            stringClass;
   int            unloaded;

   manager = [NSFileManager defaultManager];
   cwd     = [manager currentDirectoryPath];
   path    = [cwd stringByAppendingPathComponent:@"EmptyBundle.bundle"];

   bundle = [NSBundle bundleWithPath:path];
   if( ! bundle)
   {
      mulle_printf( "FAIL: could not create bundle\n");
      return( 1);
   }

   mainBundle   = [NSBundle mainBundle];
   nilClass     = ([NSBundle bundleForClass:nil] == nil);
   stringClass  = ([NSBundle bundleForClass:[NSString class]] != nil);

   byIdentifier    = [NSBundle bundleWithIdentifier:@"com.mulle-kybernetik.foundation"];
   mainIdentifier  = (byIdentifier == mainBundle);
   falseIdentifier = ([NSBundle bundleWithIdentifier:@"com.none.NoSuchBundle"] == nil);
   nilIdentifier   = ([NSBundle bundleWithIdentifier:nil] == nil);

   localizations = ([bundle localizations] == nil);
   preferred     = ([bundle preferredLocalizations] == nil);
   localizedInfo = ([bundle localizedInfoDictionary] == [bundle infoDictionary]);
   loaded        = ([bundle isLoaded] == NO);
   unloaded      = ([bundle unloadBundle] == NO);
   classNamed    = ([bundle classNamed:@"NSString"] == [NSString class]);

   mulle_printf( "nil-class=%d\n", nilClass ? 1 : 0);
   mulle_printf( "string-class=%d\n", stringClass ? 1 : 0);
   mulle_printf( "main-identifier=%d\n", mainIdentifier ? 1 : 0);
   mulle_printf( "false-identifier=%d\n", falseIdentifier ? 1 : 0);
   mulle_printf( "nil-identifier=%d\n", nilIdentifier ? 1 : 0);
   mulle_printf( "localizations-nil=%d\n", localizations ? 1 : 0);
   mulle_printf( "preferred-nil=%d\n", preferred ? 1 : 0);
   mulle_printf( "localized-info-same=%d\n", localizedInfo ? 1 : 0);
   mulle_printf( "not-loaded=%d\n", loaded ? 1 : 0);
   mulle_printf( "unload-no=%d\n", unloaded ? 1 : 0);
   mulle_printf( "class-named=%d\n", classNamed ? 1 : 0);
   return( 0);
}

//
//  current-directory.m
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
   NSFileManager   *manager;
   NSProcessInfo   *info;
   NSTask          *bad;
   NSTask          *task;
   NSString        *dir;
   NSString        *relative;
   NSString        *target;
   int             createdInCwd;
   int             createdInTarget;
   int             nonexistentThrows;
   int             relativeThrows;

   manager = [NSFileManager defaultManager];
   info    = [NSProcessInfo processInfo];

   dir = [NSTemporaryDirectory() stringByAppendingPathComponent:
             [info globallyUniqueString]];

   if( ! [manager createDirectoryAtPath:dir
            withIntermediateDirectories:YES
                             attributes:nil
                                  error:NULL])
   {
      mulle_printf( "could-not-create-directory\n");
      return( 1);
   }

   // a unique relative name, so a (buggy) child writing into the caller's
   // working directory can be detected without colliding with other tests
   relative = [[info globallyUniqueString] stringByAppendingPathExtension:@"txt"];
   target   = [dir stringByAppendingPathComponent:relative];

   [manager removeItemAtPath:target
                       error:NULL];
   [manager removeItemAtPath:relative
                       error:NULL];

   task = [[[NSTask alloc] init] autorelease];

#ifdef _WIN32
   [task setLaunchPath:@"cmd.exe"];
   [task setArguments:@[ @"/c",
                         [@"echo hello > " stringByAppendingString:relative] ]];
#else
   [task setLaunchPath:@"/bin/sh"];
   [task setArguments:@[ @"-c",
                         [@"echo hello > " stringByAppendingString:relative] ]];
#endif
   [task setCurrentDirectoryPath:dir];
   [task launch];
   [task waitUntilExit];

   createdInTarget = [manager fileExistsAtPath:target];
   createdInCwd    = [manager fileExistsAtPath:relative];

   // a non-existent working directory must fail the launch, not be ignored
   nonexistentThrows = 0;
   @try
   {
      bad = [[[NSTask alloc] init] autorelease];
      [bad setLaunchPath:[task launchPath]];
      [bad setArguments:[task arguments]];
      [bad setCurrentDirectoryPath:[dir stringByAppendingPathComponent:@"does-not-exist"]];
      [bad launch];
   }
   @catch( NSException *exception)
   {
      nonexistentThrows = 1;
   }

   // a relative working directory is rejected
   relativeThrows = 0;
   @try
   {
      bad = [[[NSTask alloc] init] autorelease];
      [bad setCurrentDirectoryPath:@"relative"];
   }
   @catch( NSException *exception)
   {
      relativeThrows = 1;
   }

   mulle_printf( "created-in-target=%d\n", createdInTarget ? 1 : 0);
   mulle_printf( "created-in-cwd=%d\n", createdInCwd ? 1 : 0);
   mulle_printf( "nonexistent-throws=%d\n", nonexistentThrows ? 1 : 0);
   mulle_printf( "relative-throws=%d\n", relativeThrows ? 1 : 0);

   [manager removeItemAtPath:dir
                       error:NULL];
   [manager removeItemAtPath:relative
                       error:NULL];
   return( 0);
}

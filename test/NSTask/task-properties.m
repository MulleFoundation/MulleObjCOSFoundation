//
//  task-properties.m
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
   NSTask        *task;
   NSPipe        *pipe;
   NSArray       *arguments;
   NSDictionary  *environment;
   int           defaultArguments;
   int           defaultCurrentDirectory;
   int           defaultEnvironment;
   int           defaultLaunchPath;
   int           defaultStandardOutput;
   int           environmentRoundtrip;
   int           launchPathRoundtrip;
   int           outputIdentity;
   int           outputIsPipe;

   task = [[NSTask new] autorelease];

   // unset accessors fall back to process defaults / nil
   defaultLaunchPath       = ([task launchPath] == nil);
   defaultArguments        = ([task arguments] == nil);
   defaultCurrentDirectory = [[task currentDirectoryPath] isEqualToString:[[NSFileManager defaultManager] currentDirectoryPath]];
   defaultEnvironment      = [[task environment] isEqualToDictionary:[[NSProcessInfo processInfo] environment]];
   defaultStandardOutput   = [[task standardOutput] isKindOfClass:[NSFileHandle class]];

   // set/get roundtrip
   [task setLaunchPath:@"/bin/echo"];
   [task setArguments:@[ @"a", @"b" ]];
   [task setEnvironment:@{ @"A": @"B" }];
   [task setCurrentDirectoryPath:@"/"];

   pipe = [NSPipe pipe];
   [task setStandardOutput:pipe];

   launchPathRoundtrip = [[task launchPath] isEqualToString:@"/bin/echo"];
   arguments           = [task arguments];
   environment         = [task environment];

   environmentRoundtrip = ([arguments count] == 2
                           && [environment count] == 1
                           && [[task currentDirectoryPath] isEqualToString:@"/"]);
   outputIdentity       = ([task standardOutput] == pipe);
   outputIsPipe         = ([[task standardOutput] isKindOfClass:[NSPipe class]]);

   mulle_printf( "default-launch-path=%d\n", defaultLaunchPath ? 1 : 0);
   mulle_printf( "default-arguments=%d\n", defaultArguments ? 1 : 0);
   mulle_printf( "default-current-directory=%d\n", defaultCurrentDirectory ? 1 : 0);
   mulle_printf( "default-environment=%d\n", defaultEnvironment ? 1 : 0);
   mulle_printf( "default-standard-output=%d\n", defaultStandardOutput ? 1 : 0);
   mulle_printf( "launch-path-roundtrip=%d\n", launchPathRoundtrip ? 1 : 0);
   mulle_printf( "environment-roundtrip=%d\n", environmentRoundtrip ? 1 : 0);
   mulle_printf( "output-identity=%d\n", outputIdentity ? 1 : 0);
   mulle_printf( "output-is-pipe=%d\n", outputIsPipe ? 1 : 0);
   return( 0);
}

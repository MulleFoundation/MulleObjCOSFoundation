//
//  task-lifecycle.m
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
   NSTask    *task;
   NSInteger status;
   int       resume;
   int       running;
   int       suspend;

   task = [[NSTask new] autorelease];

#ifdef _WIN32
   [task setLaunchPath:@"cmd.exe"];
   [task setArguments:@[ @"/c", @"exit", @"0" ]];
#else
   [task setLaunchPath:@"/bin/sh"];
   [task setArguments:@[ @"-c", @"exit 0" ]];
#endif

   [task launch];
   [task waitUntilExit];

   running = [task isRunning];
   status  = [task terminationStatus];

   // all of these must be no-ops on a terminated task
   [task terminate];
   [task interrupt];
   suspend = [task suspend];
   resume  = [task resume];

   mulle_printf( "running-after=%d\n", running ? 1 : 0);
   mulle_printf( "status=%d\n", (int) status);
   mulle_printf( "suspend=%d\n", suspend ? 1 : 0);
   mulle_printf( "resume=%d\n", resume ? 1 : 0);
   return( 0);
}

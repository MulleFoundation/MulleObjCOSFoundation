//
//  task-terminate.m
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

#ifdef _WIN32
# include <windows.h>
#else
# include <unistd.h>
#endif
#include <stdio.h>
#include <string.h>


//
// When invoked with the "child" argument the process just sleeps for a
// while. The parent launches this very executable as a task and then
// terminates it. That gives a long-running task on every platform without
// depending on external utilities.
//
static void   childSleep( void)
{
#ifdef _WIN32
   Sleep( 30000);
#else
   sleep( 30);
#endif
}


int   main( int argc, const char * argv[])
{
   NSTask                   *task;
   NSProcessInfo            *info;
   NSTaskTerminationReason  reason;
   NSString                 *exePath;
   NSInteger                status;
   int                      running;

   if( argc > 1 && strcmp( argv[ 1], "child") == 0)
   {
      childSleep();
      return( 0);
   }

   info    = [NSProcessInfo processInfo];
   exePath = [info _executablePath];

   task = [[NSTask new] autorelease];
   [task setLaunchPath:exePath];
   [task setArguments:@[ @"child" ]];

   [task launch];

   running = [task isRunning];
   [task terminate];
   [task waitUntilExit];

   status = [task terminationStatus];
   reason = [task terminationReason];

   mulle_printf( "running=%d\n", running ? 1 : 0);
   mulle_printf( "status=%d\n", (int) status);
   mulle_printf( "reason=%d\n", (int) reason);
   return( 0);
}

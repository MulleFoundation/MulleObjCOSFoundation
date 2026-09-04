//
//  NSTask.h
//  MulleObjCOSFoundation
//
//  Copyright (c) 2020 Nat! - Mulle kybernetiK.
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
#import "import.h"


enum
{
   NSTaskTerminationReasonExit           = 1,
   NSTaskTerminationReasonUncaughtSignal = 2
};

typedef NSInteger   NSTaskTerminationReason;


@class NSArray;
@class NSDictionary;
@class NSString;
@class NSFileHandle;


@interface NSTask : NSObject
{
   NSString      *_launchPath;
   NSArray       *_arguments;
   NSString      *_directoryPath;
   NSDictionary  *_environment;

   id            _standardError;
   id            _standardInput;
   id            _standardOutput;

   int           _pid;
   int           _status;
   int           _terminationStatus;
   void          *_taskHandle;  // Windows process HANDLE
}


+ (NSTask *) launchedTaskWithLaunchPath:(NSString *) path
                              arguments:(NSArray *) arguments;

- (void) setArguments:(NSArray *) arguments;
- (void) setCurrentDirectoryPath:(NSString *) path;
- (void) setEnvironment:(NSDictionary *) environmentDictionary;
- (void) setLaunchPath:(NSString *) path;
- (void) setStandardError:(id) file;
- (void) setStandardInput:(id) file;
- (void) setStandardOutput:(id) file;

- (NSInteger) processIdentifier;
- (NSInteger) terminationStatus;

- (id) standardError;
- (id) standardInput;
- (id) standardOutput;

- (NSArray *) arguments;
- (NSString *) launchPath;
- (NSString *) currentDirectoryPath;
- (NSDictionary *) environment;

@end


@interface NSTask( Future) < MulleObjCFuture>

+ (char **) _environment;

- (BOOL) isRunning;

- (void) interrupt;
- (void) launch;
- (BOOL) resume;
- (BOOL) suspend;
- (void) terminate;
- (void) waitUntilExit;
- (NSTaskTerminationReason) terminationReason;

@end




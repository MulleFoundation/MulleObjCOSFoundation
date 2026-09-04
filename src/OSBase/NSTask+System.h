//
//  NSTask+System.h
//  MulleObjCOSFoundation
//
//  Copyright (c) 2023 Nat! - Mulle kybernetiK.
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
#import "NSTask.h"


// TODO: move this into own library

typedef NS_ENUM( int, NSTaskSystemOptions)
{
   NSTaskSystemSendStandardInput     = 0x1,
   NSTaskSystemReceiveStandardOutput = 0x2,
   NSTaskSystemReceiveStandardError  = 0x4
};

#define NSTaskSystemOptionsDefault  (NSTaskSystemSendStandardInput|NSTaskSystemReceiveStandardOutput|NSTaskSystemReceiveStandardError)

MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSTaskExceptionKey;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSTaskTerminationStatusKey;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSTaskStandardOutputDataKey;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSTaskStandardOutputStringKey;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSTaskStandardErrorDataKey;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSTaskStandardErrorStringKey;


// just so convenient...

@interface NSTask( System)

// environment will be _added_ to the current environment, this is
// not just a -[NSTask setEnvironment:]
+ (NSDictionary *) mulleDataSystemCallWithArguments:(NSArray *) argv
                                        environment:(NSDictionary *) environment
                                   workingDirectory:(NSString *) dir
                                  standardInputData:(NSData *) inputData
                                            options:(NSTaskSystemOptions) options;


+ (NSDictionary *) mulleDataSystemCallWithArguments:(NSArray *) argv
                                   workingDirectory:(NSString *) dir
                                  standardInputData:(NSData *) inputData
                                            options:(NSTaskSystemOptions) options;

+ (NSDictionary *) mulleDataSystemCallWithArguments:(NSArray *) argv
                                        environment:(NSDictionary *) environment
                                  standardInputData:(NSData *) data;


// as above, but everything is with NSString instead of NSData, arguments
// are in an NSArray, exceptions are flattened into the same return values
// as a successful call, just with terminationStatus -1, the exception reason
// is in stdout
+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv
                                          environment:(NSDictionary *) environment
                                     workingDirectory:(NSString *) dir
                                  standardInputString:(NSString *) stdinString
                                              options:(NSTaskSystemOptions) options;


+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv
                                     workingDirectory:(NSString *) dir
                                  standardInputString:(NSString *) stdinString
                                              options:(NSTaskSystemOptions) options;


+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv
                                          environment:(NSDictionary *) environment
                                  standardInputString:(NSString *) stdinString;

+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv
                                  standardInputString:(NSString *) stdinString;

+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv
                                          environment:(NSDictionary *) environment;

+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv;

// even more convenient, string 's' is parsed and separated into the arguments
// array...
+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s
                                         workingDirectory:(NSString *) dir
                                              environment:(NSDictionary *) environment
                                      standardInputString:(NSString *) stdinString;

+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s
                                              environment:(NSDictionary *) environment
                                      standardInputString:(NSString *) stdinString;

+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s
                                      standardInputString:(NSString *) stdinString;

+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s
                                              environment:(NSString *) environment;

+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s;

@end



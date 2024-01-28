/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSTask+System.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, __MyCompanyName__
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSTask.h"


// TODO: move this into own library

typedef NS_ENUM( int, NSTaskSystemOptions)
{
   NSTaskSystemSendStandardInput     = 0x1,
   NSTaskSystemReceiveStandardOutput = 0x2,
   NSTaskSystemReceiveStandardError  = 0x4
};

#define NSTaskSystemOptionsDefault  (NSTaskSystemSendStandardInput|NSTaskSystemReceiveStandardOutput|NSTaskSystemReceiveStandardError)

extern NSString   *NSTaskExceptionKey;             // = @"exception";

extern NSString   *NSTaskTerminationStatusKey;     // = @"terminationStatus";
extern NSString   *NSTaskStandardOutputDataKey;    // = @"standardOutputData";
extern NSString   *NSTaskStandardOutputStringKey;  // = @"standardOutputString";
extern NSString   *NSTaskStandardErrorDataKey;     // = @"standardErrorData";
extern NSString   *NSTaskStandardErrorStringKey;   // = @"standardErrorString";


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

// even more convenient, string 's' is parsed and separated into the arguments
// array...
+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s
                                              environment:(NSDictionary *) environment
                                      standardInputString:(NSString *) stdinString;

+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s
                                      standardInputString:(NSString *) stdinString;

+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s
                                              environment:(NSString *) environment;

+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s;

@end



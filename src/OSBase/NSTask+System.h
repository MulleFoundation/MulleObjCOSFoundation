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

+ (NSDictionary *) mulleDataSystemCallWithArguments:(NSArray *) argv
                                   workingDirectory:(NSString *) dir
                                  standardInputData:(NSData *) inputData
                                            options:(NSTaskSystemOptions) options;

// as above, but everything is with NSString instead of NSData
+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv
                                     workingDirectory:(NSString *) dir
                                  standardInputString:(NSString *) stdinString
                                              options:(NSTaskSystemOptions) options;



+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv
                                  standardInputString:(NSString *) s;

+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s;

+ (NSDictionary *) mulleDataSystemCallWithArguments:(NSArray *) argv
                                  standardInputData:(NSData *) data;

@end

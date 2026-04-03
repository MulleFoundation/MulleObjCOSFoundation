//
//  main.m
//  archiver-test
//
//  Created by Nat! on 19.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//


#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
//#import "MulleStandaloneObjCFoundation.h"

#include <stdio.h>


#define KB  8


int   main( int argc, const char * argv[])
{
   NSArray         *array;
   NSData          *data;
   NSDictionary    *dictionary;
   NSMutableData   *inputData;
   NSData          *outputData;
   NSUInteger      options;

#ifdef _WIN32
   // On Windows, test basic command execution and stdout capture
   // (no cat equivalent available for stdin piping)
   options    = NSTaskSystemReceiveStandardOutput;
   dictionary = [NSTask mulleDataSystemCallWithArguments:@[ @"cmd.exe", @"/c", @"echo", @"PASS" ]
                                        workingDirectory:nil
                                       standardInputData:nil
                                                 options:options];
   if( [dictionary objectForKey:NSTaskExceptionKey])
   {
      mulle_fprintf( stderr, "failed %@\n", dictionary);
      return( 1);
   }

   outputData = [dictionary objectForKey:NSTaskStandardOutputDataKey];
   if( ! [outputData length])
   {
      mulle_fprintf( stderr, "no output received\n");
      return( 1);
   }
#else
   inputData = [NSMutableData dataWithLength:KB*1024];
   memset( [inputData mutableBytes], 'V', [inputData length]);

   options    = NSTaskSystemSendStandardInput|NSTaskSystemReceiveStandardOutput;
   dictionary = [NSTask mulleDataSystemCallWithArguments:@[ @"cat" ]
                                        workingDirectory:nil
                                       standardInputData:inputData
                                                 options:options];
   if( [dictionary objectForKey:NSTaskExceptionKey])
   {
      mulle_fprintf( stderr, "failed %@\n", dictionary);
      return( 1);
   }

   if( [dictionary count] != 3)
   {
      mulle_fprintf( stderr, "failed expectation\n");
      return( 1);
   }

   if( (options & (NSTaskSystemSendStandardInput|NSTaskSystemReceiveStandardOutput)) ==
       (NSTaskSystemSendStandardInput|NSTaskSystemReceiveStandardOutput))
   {
      outputData = [dictionary objectForKey:NSTaskStandardOutputDataKey];
      if( [outputData length] < [inputData length])
      {
         mulle_fprintf( stderr, "truncated (%ld -> %ld)\n",
                          (long) [inputData length],
                          (long) [outputData length]);
         return( 1);
      }

      if( ! [outputData isEqualToData:inputData])
      {
         mulle_fprintf( stderr, "changed:\n%.*s\nto:\n%.*s\n",
                          (int) [outputData length], (char *) [outputData bytes],
                          (int) [inputData length], (char *) [inputData bytes]);
         return( 1);
      }
   }
#endif

   return( 0);
}

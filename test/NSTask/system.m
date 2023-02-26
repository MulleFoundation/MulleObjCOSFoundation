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

   inputData = [NSMutableData dataWithLength:KB*1024];
   memset( [inputData mutableBytes], 'V', [inputData length]);

   options    = NSTaskSystemSendStandardInput|NSTaskSystemReceiveStandardOutput;
   dictionary = [NSTask mulleDataSystemCallWithArguments:@[ @"unix-cat" ]
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
      fprintf( stderr, "failed expectation\n");
      return( 1);
   }

   if( (options & (NSTaskSystemSendStandardInput|NSTaskSystemReceiveStandardOutput)) ==
       (NSTaskSystemSendStandardInput|NSTaskSystemReceiveStandardOutput))
   {
      outputData = [dictionary objectForKey:NSTaskStandardOutputDataKey];
      if( [outputData length] < [inputData length])
      {
         fprintf( stderr, "truncated (%ld -> %ld)\n",
                          (long) [inputData length],
                          (long) [outputData length]);
         return( 1);
      }

      if( ! [outputData isEqualToData:inputData])
      {
         fprintf( stderr, "changed:\n%.*s\nto:\n%.*s\n",
                          (int) [outputData length], (char *) [outputData bytes],
                          (int) [inputData length], (char *) [inputData bytes]);
         return( 1);
      }
   }

/*
   data = [array objectAtIndex:1];
   if( [data length])
   {
      fprintf( stderr, "unexpected stderr \"%.*s\"\n",
                       (int) [data length], (char *) [data bytes]);
      return( 1);
   }
*/
   return( 0);
}

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
   NSArray               *array;
   NSData                *data;
   NSData                *outputData;
   NSDictionary          *currentEnvironment;
   NSDictionary          *dictionary;
   NSMutableData         *inputData;
   NSMutableDictionary   *environment;
   NSString              *cwd;
   NSString              *path;
   NSUInteger            options;

   // test that we can pass an environment variable and also tests
   // that we can change PATH and NSTask will pick it up

   currentEnvironment = [[NSProcessInfo processInfo] environment];
   path               = [currentEnvironment :@"PATH"];
   cwd                = [[NSFileManager defaultManager] currentDirectoryPath];
   path               = [cwd stringByAppendingFormat:@":%@", path];

   environment        = [NSMutableDictionary dictionaryWithDictionary:currentEnvironment];
   [environment setObject:@"VfL Bochum 1848"
                  forKey: @"FOO"];
   [environment setObject:path
                   forKey:@"PATH"];

   options    = NSTaskSystemReceiveStandardOutput;
   dictionary = [NSTask mulleDataSystemCallWithArguments:@[ @"echo-foo.sh" ]
                                             environment:environment
                                        workingDirectory:nil
                                       standardInputData:nil
                                                 options:options];

   if( [dictionary objectForKey:NSTaskExceptionKey])
   {
      mulle_fprintf( stderr, "failed %@\n", dictionary);
      return( 1);
   }

   outputData = [dictionary objectForKey:NSTaskStandardOutputDataKey];

   // outputData will include linefeed
   printf("%.*s", (int) [outputData length], (char *) [outputData bytes]);

   return( 0);
}

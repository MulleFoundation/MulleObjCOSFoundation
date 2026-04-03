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
   NSData                *outputData;
   NSDictionary          *currentEnvironment;
   NSDictionary          *dictionary;
   NSMutableDictionary   *environment;
   NSUInteger            options;
#ifndef _WIN32
   NSString              *cwd;
   NSString              *path;
#endif

   // test that we can pass an environment variable and also tests
   // that we can change PATH and NSTask will pick it up

   currentEnvironment = [[NSProcessInfo processInfo] environment];

   environment = [NSMutableDictionary dictionaryWithDictionary:currentEnvironment];
   [environment setObject:@"VfL Bochum 1848"
                   forKey:@"FOO"];

#ifdef _WIN32
   // On Windows, use cmd.exe to echo the environment variable
   options    = NSTaskSystemReceiveStandardOutput;
   dictionary = [NSTask mulleDataSystemCallWithArguments:@[ @"cmd.exe", @"/c", @"echo", @"%FOO%" ]
                                             environment:environment
                                        workingDirectory:nil
                                       standardInputData:nil
                                                 options:options];
#else
   path = [currentEnvironment :@"PATH"];
   cwd  = [[NSFileManager defaultManager] currentDirectoryPath];
   path = [cwd stringByAppendingFormat:@":%@", path];

   [environment setObject:path
                   forKey:@"PATH"];

   options    = NSTaskSystemReceiveStandardOutput;
   dictionary = [NSTask mulleDataSystemCallWithArguments:@[ @"echo-foo.sh" ]
                                             environment:environment
                                        workingDirectory:nil
                                       standardInputData:nil
                                                 options:options];
#endif

   if( [dictionary objectForKey:NSTaskExceptionKey])
   {
      mulle_fprintf( stderr, "failed %@\n", dictionary);
      return( 1);
   }

   outputData = [dictionary objectForKey:NSTaskStandardOutputDataKey];

   // outputData will include linefeed (and \r on Windows)
   {
      const char   *bytes;
      NSUInteger   len;
      NSUInteger   i;

      bytes = [outputData bytes];
      len   = [outputData length];

      for( i = 0; i < len; i++)
         if( bytes[ i] != '\r')
            putchar( bytes[ i]);
   }

   return( 0);
}

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


int   main( int argc, const char * argv[])
{
   NSString        *cString;
   NSString        *s;

   s = [[NSProcessInfo processInfo] _executablePath];
   if( ! s)
   {
      mulle_printf( "fail\n");
      return( -1);
   }

   cString = [NSString stringWithCString:(char *) argv[ 0]];

   // the emulator may invoke us with a relative argv[0]
   if( ! [cString isAbsolutePath])
      cString = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:cString];

   // Normalize both to Unix format for cross-platform comparison
   s       = [[s mulleUnixFileSystemString] stringByStandardizingPath];
   cString = [[cString mulleUnixFileSystemString] stringByStandardizingPath];

   if( ! [s isEqualToString:cString])
      mulle_printf( "failed\n");

   return( 0);
}

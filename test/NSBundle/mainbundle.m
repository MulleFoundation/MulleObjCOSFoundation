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


int   main( int argc, char * argv[])
{
   NSString        *argv_exe;
   NSString        *bundle_exe;
   NSBundle        *bundle;

   bundle = [NSBundle mainBundle];

   mulle_fprintf( stderr, "DEBUG: Bundle: %p\n", bundle);

   if( ! bundle)
   {
      mulle_printf( "fail\n");
      return( -1);
   }

   bundle_exe = [bundle executablePath];
   argv_exe   = [NSString stringWithCString:argv[ 0]];

   // Normalize both to Unix format for comparison
   bundle_exe = [bundle_exe mulleUnixFileSystemString];
   argv_exe   = [argv_exe mulleUnixFileSystemString];

   mulle_fprintf( stderr, "DEBUG: argv[0]:    '%s'\n", argv[ 0]);
   mulle_fprintf( stderr, "DEBUG: argv_exe:   '%s'\n", [argv_exe UTF8String]);
   mulle_fprintf( stderr, "DEBUG: bundle_exe: '%s'\n", bundle_exe ? [bundle_exe UTF8String] : "(nil)");

   if( ! [argv_exe isEqualToString:bundle_exe])
   {
      mulle_printf( "failed: %s <> %s\n",
               [bundle_exe UTF8String],
               [argv_exe UTF8String]);
      return( -1);
   }
   return( 0);
}

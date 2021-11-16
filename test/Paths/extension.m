//
//  main.m
//  archiver-test
//
//  Created by Nat! on 19.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//


#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
//#import "MulleStandaloneObjCFoundation.h"



static void  test( char *s, char *expect)
{
   NSString   *ext;
   NSString   *path;

   path = [NSString stringWithUTF8String:s];
   ext  = [path pathExtension];
   printf( "%s\n", strcmp( [ext UTF8String], expect) ? "failed" : "passed");
}


int   main( int argc, const char * argv[])
{
   test( "/tmp/scratch.tiff", "tiff");
   test( ".scratch.tiff", "tiff");
   test( "/tmp/scratch", "");
   test( "/tmp/", "");
   test( "/tmp/scratch..tiff", "tiff");
   test( "/tmp/scratch.", "");

   return( 0);
}

//
//  main.m
//  archiver-test
//
//  Created by Nat! on 19.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#ifdef __MULLE_OBJC__
# import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
#else
# import <Foundation/Foundation.h>
# pragma message( "Apple Foundation")
#endif


#include <stdio.h>


int   main( int argc, const char * argv[])
{
   id   contents;

   contents = [[NSFileManager defaultManager] directoryContentsAtPath:@"demo"];
   printf( "%s\n", [[contents description] UTF8String]);

   return( 0);
}


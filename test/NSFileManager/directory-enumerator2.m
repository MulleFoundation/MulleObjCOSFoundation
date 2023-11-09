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
   NSEnumerator   *rover;
   NSArray        *contents;

   rover    = [[NSFileManager defaultManager] enumeratorAtPath:@"demo2"];
   contents = [rover allObjects];
   contents = [contents sortedArrayUsingSelector:@selector( compare:)];
   printf( "%s\n", [[contents description] UTF8String]);

   return( 0);
}


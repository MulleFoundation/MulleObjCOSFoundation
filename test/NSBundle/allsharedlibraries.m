//
//  main.m
//  archiver-test
//
//  Created by Nat! on 19.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
#import <MulleObjCOSBaseFoundation/NSBundle-Private.h>

//#import "MulleStandaloneObjCFoundation.h"

#include <stdio.h>


int   main( int argc, const char * argv[])
{
   NSData                           *data;
   struct _MulleObjCSharedLibrary   *p;
   struct _MulleObjCSharedLibrary   *sentinel;

   data     = [NSBundle _allSharedLibraries];
   p        = [data bytes];
   sentinel = (struct _MulleObjCSharedLibrary *) &((char *)p )[ [data length]];

   mulle_fprintf( stderr, "Informational output only (not checked):\n");
   while( p < sentinel)
   {
      mulle_fprintf( stderr, "path   : %s\n", [p->path UTF8String]);
      mulle_fprintf( stderr, "start  : %p\n", p->start);
      mulle_fprintf( stderr, "end    : %p\n", p->end);
      mulle_fprintf( stderr, "handle : %p\n", p->handle);
      ++p;
   }

   return( 0);
}

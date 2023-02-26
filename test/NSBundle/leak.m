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


int   main( int argc, const char * argv[])
{
   NSBundle                         *bundle;
   NSString                         *path;
   NSString                         *mainExecutablePath;
   NSBundle                         *mainBundle;
   NSData                           *sharedLibraryInfo;
   struct _MulleObjCSharedLibrary   *infoLibs;
   struct _MulleObjCSharedLibrary   *sentinel;
   NSUInteger                       nInfoLibs;
   NSDictionary                     *dict;
   NSUInteger                       max;

   max = 0;
   if( argc == 2)
      max = atoi( argv[ 1]);
   max = max ? max : 16;

   mainBundle         = [NSBundle mainBundle];
   mainExecutablePath = [mainBundle executablePath];
   assert( mainExecutablePath);

   sharedLibraryInfo = [NSBundle _allSharedLibraries];
   infoLibs          = [sharedLibraryInfo bytes];
   nInfoLibs         = [sharedLibraryInfo length] / sizeof( struct _MulleObjCSharedLibrary);
   nInfoLibs         = nInfoLibs > max ? max : nInfoLibs;
   sentinel          = &infoLibs[ nInfoLibs];
   fprintf( stderr, "shared: %td\n", nInfoLibs);

   while( infoLibs < sentinel)
   {
      fprintf( stderr, "%p\n", infoLibs);
      path = [NSBundle _bundlePathForExecutablePath:infoLibs->path];

      // superflous check ?
      if( ! mainExecutablePath || ! [path isEqualToString:mainExecutablePath])
      {
         bundle = [[[NSBundle alloc] _mulleInitWithPath:path
                                      sharedLibraryInfo:infoLibs] autorelease];
      }
      infoLibs++;
   }

   return( 0);
}

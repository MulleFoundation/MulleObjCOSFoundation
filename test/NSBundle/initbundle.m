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

extern NSBundle  *(*NSBundleGetOrRegisterBundleWithPath)( NSBundle *bundle, NSString *path);

int   main( int argc, char * argv[])
{
   NSBundle                         *bundle;
   struct _MulleObjCSharedLibrary   info;

   info.path   = @"otherPath"; // ???
   info.start  = (void *) 18;
   info.end    = (void *) 48;
   info.handle = NULL;

   bundle = [[[NSBundle alloc] _mulleInitWithPath:@"/tmp/info.path"
                                sharedLibraryInfo:&info] autorelease];
   (*NSBundleGetOrRegisterBundleWithPath)( bundle, [bundle bundlePath]);

   return( 0);
}

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
   NSString  *path;

   path = [NSBundle _bundlePathForExecutablePath:[NSString stringWithUTF8String:argv[ 0]]];

   return( 0);
}

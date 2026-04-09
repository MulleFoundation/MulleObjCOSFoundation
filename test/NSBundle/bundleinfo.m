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
#endif

//#import "MulleStandaloneObjCFoundation.h"

#include <stdio.h>

@interface NSBundle (Forward)
+ (NSDictionary *) mulleRegisteredBundleInfo;
@end


int   main( int argc, const char * argv[])
{
   NSDictionary   *bundleInfo;

   // not much we can check here
   bundleInfo = [NSBundle mulleRegisteredBundleInfo];

#if 0
   mulle_fprintf( stderr, "Informational output only (not checked):\n");
   for( bundle in bundles)
   {
      mulle_fprintf( stderr, "bundlePath     : %s\n", [[bundle bundlePath] UTF8String]);
      mulle_fprintf( stderr, "executablePath : %s\n", [[bundle executablePath] UTF8String]);
      mulle_fprintf( stderr, "resourcePath   : %s\n", [[bundle resourcePath] UTF8String]);
      mulle_fprintf( stderr, "isLoaded       : %s\n", [bundle isLoaded] ? "YES" : "NO");
   }
#endif
   return( 0);
}

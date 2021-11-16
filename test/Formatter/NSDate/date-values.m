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




int   main( int argc, const char * argv[])
{
   NSDate            *date;

   date = [[[NSDate alloc] initWithTimeIntervalSince1970:0] autorelease];
   printf( "1970: %s (%0.17g)\n", [[date description] UTF8String], [date timeIntervalSinceReferenceDate]);

   date = [[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:0] autorelease];
   printf( "ReferenceDate: %s (%0.17g)\n", [[date description] UTF8String], [date timeIntervalSinceReferenceDate]);

   return( 0);
}

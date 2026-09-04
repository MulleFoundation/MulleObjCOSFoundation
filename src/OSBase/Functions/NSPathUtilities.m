//
//  NSPathUtilities.m
//  MulleObjCOSFoundation
//
//  Copyright (c) 2020 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
#import "NSPathUtilities.h"

// other files in this library
#import "NSPathUtilities+OSBase-Private.h"
#import "NSString+OSBase.h"

// std-c and dependencies

MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
_NSPathUtilityVectorTable   *_NSPathUtilityVectors;


static struct
{
   NSString  *NSFullUserName;
   NSString  *NSHomeDirectory;
   NSString  *NSOpenStepRootDirectory;
   NSString  *NSTemporaryDirectory;
   NSString  *NSUserName;
} NSPathCache;



static NSString   *standardizedPath( NSString *s)
{
   s  = [s mulleStringBySimplifyingPath];
   return( s);
}


NSString  *NSFullUserName( void)
{
   NSString   *s;

   NSCParameterAssert( _NSPathUtilityVectors);
   if( NSPathCache.NSFullUserName)
      return( NSPathCache.NSFullUserName);

   s = (*_NSPathUtilityVectors->NSFullUserName)();
   NSPathCache.NSFullUserName = [s retain];

   return( NSPathCache.NSFullUserName);
}


NSString  *NSHomeDirectory( void)
{
   NSString   *s;

   NSCParameterAssert( _NSPathUtilityVectors);
   if( NSPathCache.NSHomeDirectory)
      return( NSPathCache.NSHomeDirectory);

   s = (*_NSPathUtilityVectors->NSHomeDirectory)();
   NSCParameterAssert( [s isEqualToString:standardizedPath( s)]);
   NSPathCache.NSHomeDirectory = [s retain];
   return( NSPathCache.NSHomeDirectory);
}


NSString  *NSHomeDirectoryForUser( NSString *userName)
{
   NSString   *s;

   NSCParameterAssert( _NSPathUtilityVectors);
   NSCParameterAssert( [userName isKindOfClass:[NSString class]]);

   s = (*_NSPathUtilityVectors->NSHomeDirectoryForUser)( userName);
   return( s);
}


NSString  *NSOpenStepRootDirectory( void)
{
   NSString   *s;

   NSCParameterAssert( _NSPathUtilityVectors);

   if( NSPathCache.NSOpenStepRootDirectory)
      return( NSPathCache.NSOpenStepRootDirectory);

   s = (*_NSPathUtilityVectors->NSOpenStepRootDirectory)();
   NSCParameterAssert( [s isEqualToString:standardizedPath( s)]);
   NSPathCache.NSOpenStepRootDirectory = [s retain];
   return( NSPathCache.NSOpenStepRootDirectory);
}


NSArray   *NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory directory,
                                                NSSearchPathDomainMask domainMask,
                                                BOOL expandTilde)
{
   NSMutableArray   *array;
   NSArray          *result;
   NSString         *s;

   result = (*_NSPathUtilityVectors->_NSSearchPathForDirectoriesInDomains)( directory, domainMask);

   array = [NSMutableArray array];
   for( s in result)
   {
      if( expandTilde)
         s = [s stringByExpandingTildeInPath];
      s = standardizedPath( s);

      [array addObject:s];
   }
   return( array);
}


NSString  *NSTemporaryDirectory( void)
{
   NSString   *s;

   NSCParameterAssert( _NSPathUtilityVectors);

   if( NSPathCache.NSTemporaryDirectory)
      return( NSPathCache.NSTemporaryDirectory);

   s = (*_NSPathUtilityVectors->NSTemporaryDirectory)();
   NSCParameterAssert( [s isEqualToString:standardizedPath( s)]);
   NSPathCache.NSTemporaryDirectory = [s retain];

   return( NSPathCache.NSTemporaryDirectory);
}


NSString  *NSUserName( void)
{
   NSString   *s;

   NSCParameterAssert( _NSPathUtilityVectors);

   if( NSPathCache.NSUserName)
      return( NSPathCache.NSUserName);

   s = (*_NSPathUtilityVectors->NSUserName)();
   NSCParameterAssert( [s isEqualToString:standardizedPath( s)]);
   NSPathCache.NSUserName = [s retain];
   return( NSPathCache.NSUserName);
}


#pragma clang diagnostic ignored "-Wobjc-root-class"

@implementation _NSPathUtilityVectorTable_Loader

MULLE_OBJC_DEPENDS_ON_LIBRARY( MulleObjCStandardFoundation);


+ (NSUInteger) _getOwnedObjects:(id *) objects
                          count:(NSUInteger) count
{
   return( MulleObjCCopyObjects( objects,
                                 count,
                                 5,
                                 NSPathCache.NSFullUserName,
                                 NSPathCache.NSHomeDirectory,
                                 NSPathCache.NSOpenStepRootDirectory,
                                 NSPathCache.NSTemporaryDirectory,
                                 NSPathCache.NSUserName));
}


+ (void) unload
{
   [NSPathCache.NSFullUserName release];
   [NSPathCache.NSHomeDirectory release];
   [NSPathCache.NSOpenStepRootDirectory release];
   [NSPathCache.NSTemporaryDirectory release];
   [NSPathCache.NSUserName release];
}

@end


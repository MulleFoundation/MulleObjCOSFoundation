//
//  NSPathUtilities+FreeBSD.m
//  MulleObjCOSFoundation
//
//  Copyright (c) 2016 Nat! - Mulle kybernetiK.
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
#import "import-private.h"

#import <MulleObjCOSBaseFoundation/NSPathUtilities+OSBase-Private.h>

// other files in this library

// other libraries of MulleObjCPosixFoundation


static NSString   *FreeBSDHomeDirectory( void)
{
   char  *s;

   s = getenv( "HOME");
   if( s)
      return( [NSString stringWithCString:s]);
   return( @"");
}


static NSString   *FreeBSDRootDirectory( void)
{
   return( @"/");
}


static NSString   *FreeBSDTemporaryDirectory( void)
{
   char  *s;

   s = getenv( "TMPDIR");
   if( ! s)
      s = "/tmp";

   return( [NSString stringWithCString:s]);
}


static NSString   *FreeBSDUserName( void)
{
   char  *s;

   s = getenv( "USER");
   if( ! s)
      s = getenv( "LOGNAME");

   return( [NSString stringWithCString:s]);
}



static NSArray   *FreeBSDSearchPathForDirectoriesInDomains( NSSearchPathDirectory type,
                                                         NSSearchPathDomainMask domains)
{
   NSMutableArray          *array;
   NSSearchPathDomainMask  currentDomain;
   NSSearchPathDomainMask  leftoverDomains;
   NSString                *path;
   NSString                *prefix;
   NSString                *systemRoot;

   systemRoot      = NSOpenStepRootDirectory();
   array           = [NSMutableArray array];
   leftoverDomains = domains & (NSUserDomainMask|NSLocalDomainMask|NSNetworkDomainMask|NSSystemDomainMask);

   NSCParameterAssert( [systemRoot length]);

   while( leftoverDomains)
   {
      if( leftoverDomains & NSUserDomainMask)
      {
         currentDomain = NSUserDomainMask;
         prefix        = @"~";
      }
      else
         if( leftoverDomains & NSLocalDomainMask)
         {
            currentDomain = NSLocalDomainMask;
            prefix        = @"/usr/lib";
         }
         else
            if( leftoverDomains & NSNetworkDomainMask)
            {
               currentDomain = NSNetworkDomainMask;
               prefix        = @"/var/net";   // no idea
            }
            else
            {
               currentDomain = NSSystemDomainMask;
               prefix        = systemRoot;
            }

      leftoverDomains &= ~currentDomain;

      path = nil;
      switch( type)
      {
      case NSAllApplicationsDirectory : // fake but better than nothing
         break;

      case NSAllLibrariesDirectory  :
         break;

      default  :
         break;
      }
   }
   return( array);
}


static _NSPathUtilityVectorTable   _FreeBSDTable =
{
   FreeBSDUserName,
   FreeBSDHomeDirectory,
   NULL,
   FreeBSDSearchPathForDirectoriesInDomains,
   FreeBSDRootDirectory,
   FreeBSDTemporaryDirectory,
   FreeBSDUserName
};



@implementation _NSPathUtilityVectorTable_Loader( Darwin)

@dependency _NSPathUtilityVectorTable_Loader;


+ (void) load
{
   _NSPathUtilityVectors = &_FreeBSDTable;
}

@end

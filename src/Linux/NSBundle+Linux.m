//
//  NSBundle+Linux.m
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
#define _GNU_SOURCE

#import "import-private.h"

// other files in this library
#import <MulleObjCOSBaseFoundation/NSBundle-Private.h>

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <link.h>


@implementation NSBundle (Linux)

@dependency NSBundle( Posix);


static int  collect_filesystem_libraries( struct dl_phdr_info *info,
                                          size_t size,
                                          void *userinfo)
{
   NSFileManager                    *manager;
   NSMutableData                    *data;
   size_t                           len;
   uintptr_t                        section_end;
   unsigned int                     i;
   unsigned int                     n;
   struct _MulleObjCSharedLibrary   libInfo;


   // binary itself has no name it seems

   len = strlen( info->dlpi_name);
   if( ! len)
      return( 0);
   // no absolute path ? injected by kernel
   if( info->dlpi_name[ 0] != '/')
      return( 0);

   libInfo.start  = (void *) info->dlpi_addr;
   libInfo.end    = libInfo.start;
   libInfo.handle = NULL;

   n = info->dlpi_phnum;
   for( i = 0; i < n; i++)
   {
      section_end = (uintptr_t) (libInfo.start +
                                 info->dlpi_phdr[i].p_vaddr +
                                 info->dlpi_phdr[i].p_memsz);
      if( section_end > (uintptr_t) libInfo.end)
         libInfo.end = (void *) section_end;
   }

   manager      = [NSFileManager defaultManager];
   libInfo.path = [manager stringWithFileSystemRepresentation:(char *) info->dlpi_name
                                                       length:len];
   data = userinfo;
   [data appendBytes:&libInfo
              length:sizeof( libInfo)];

   return( 0);
}


+ (NSData *) _allSharedLibraries
{
   NSMutableData  *data;

   data = [NSMutableData data];
   dl_iterate_phdr( collect_filesystem_libraries, data);
   return( data);
}


+ (BOOL) isBundleFilesystemExtension:(NSString *) extension
{
   return( [extension isEqualToString:@"so"]);
}

@end

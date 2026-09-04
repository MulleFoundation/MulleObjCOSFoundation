//
//  NSPageAllocation.m
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
#define _GNU_SOURCE  // ugliness
#define _ISOC11_SOURCE

#include "NSPageAllocation.h"

// other files in this library
#include "NSPageAllocation-Private.h"

// std-c and dependencies
#include <mulle-mmap/mulle-mmap.h>

# pragma mark - Allocations

static NSUInteger   _ns_page_size;
static NSUInteger   _ns_log_page_size;


void  _MulleObjCSetPageSize( size_t pagesize)
{
   size_t   size;

   size = pagesize ? pagesize : 0x1000;

   _ns_page_size     = size;
   _ns_log_page_size = 1;
   while( size >>= 1)
      _ns_log_page_size++;
}


NSUInteger   NSPageSize( void)
{
   if( ! _ns_log_page_size)
      _MulleObjCSetPageSize( mulle_mmap_get_system_pagesize());
   
   return( _ns_page_size);
}


NSUInteger   NSLogPageSize( void)
{
   if( ! _ns_log_page_size)
      _MulleObjCSetPageSize( mulle_mmap_get_system_pagesize());
   
   return( _ns_log_page_size);
}


void   *NSAllocateMemoryPages( NSUInteger size)
{
   size = NSRoundUpToMultipleOfPageSize( size);
   return( mulle_mmap_alloc_pages( size));
}


void   NSDeallocateMemoryPages( void *ptr, NSUInteger size)
{
   if( ! ptr)
      return;
   
   size = NSRoundUpToMultipleOfPageSize( size);
   mulle_mmap_free_pages( ptr, size);
}



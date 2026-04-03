/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSPageAllocation.c is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
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



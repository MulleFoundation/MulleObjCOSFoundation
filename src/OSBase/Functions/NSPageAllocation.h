/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  MulleObjCAllocation.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "import.h"


// These are OS specific
MULLE_OBJC_OSBASE_FOUNDATION_GLOBAL
void   *NSAllocateMemoryPages( NSUInteger size);

MULLE_OBJC_OSBASE_FOUNDATION_GLOBAL
void   NSDeallocateMemoryPages( void *ptr, NSUInteger size);


MULLE_OBJC_OSBASE_FOUNDATION_GLOBAL
NSUInteger   NSPageSize( void);

MULLE_OBJC_OSBASE_FOUNDATION_GLOBAL
NSUInteger   NSLogPageSize( void);


static inline NSUInteger   NSRoundDownToMultipleOfPageSize(NSUInteger bytes)
{
   return( bytes & ~(NSPageSize() - 1));
}


static inline NSUInteger   NSRoundUpToMultipleOfPageSize( NSUInteger bytes)
{
   return( NSRoundDownToMultipleOfPageSize( bytes + NSPageSize() - 1));
}


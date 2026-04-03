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

#import "import-private.h"

// other files in this library

// std-c and dependencies
#include <stdlib.h>
#include <errno.h>
#include <mulle-mmap/mulle-mmap.h>


# pragma mark - Allocations

// Note: NSAllocateMemoryPages and NSDeallocateMemoryPages are now
// implemented in NSPageAllocation.m using mulle-mmap for cross-platform support

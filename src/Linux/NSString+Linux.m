/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSString+Darwin.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "MulleObjCPosixFoundation.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies


@implementation NSString( Linux)


// should probably query system locale or something

- (NSString *) _stringByRemovingPrivatePrefix
{
   return( self);
}


- (NSUInteger) cStringLength
{
   return( [self _UTF8StringLength]);
}


- (char *) cString
{
   return( (char *) [self UTF8String]);
}


- (NSStringEncoding) _cStringEncoding
{
   return( NSUTF8StringEncoding);
}


+ (NSStringEncoding) defaultCStringEncoding
{
   return( NSUTF8StringEncoding);
}

@end
/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSTask+Posix-Private.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, __MyCompanyName__
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */

enum
{
   _NSTaskIsIdle              = 0,
   _NSTaskHasFailedLaunching  = -1,
   _NSTaskIsPresumablyRunning = 1,
   _NSTaskHasTerminated       = 2
};

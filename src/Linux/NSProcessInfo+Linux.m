/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSProcessInfo+Darwin.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#define _GNU_SOURCE

#import "import-private.h"


// other files in this library

// other libraries of MulleObjCPosixFoundation
#import <MulleObjCOSBaseFoundation/NSArray+OSBase-Private.h>
#import <MulleObjCOSBaseFoundation/NSDictionary+OSBase-Private.h>

// std-c and dependencies
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>


@implementation NSProcessInfo( Linux)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCPosixFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}


struct argc_argv
{
   int    argc;
   char   **argv;
};


static size_t   get_file_size( char *file)
{
   char      buf[ 0x200];
   ssize_t   bytes;
   size_t    total;
   int       fd;

   fd = open( "/proc/self/cmdline", O_RDONLY);
   if( fd == -1)
      return( -1);

   total = 0;
   for(;;)
   {
      bytes = read( fd, buf, sizeof( buf));
      if( ! bytes)
	      break;
      if( bytes == -1)
      {
         total = -1;
         break;
      }
      total += bytes;
   }

   close( fd);
   return( total);
}


static char  *get_arguments( size_t *p_size)
{
   char     *buf;
   int      fd;
   size_t   size;

   size = get_file_size( "/proc/self/cmdline");
   if( size == -1)
       return( NULL);

   fd = open( "/proc/self/cmdline", O_RDONLY);
   if( fd == -1)
      return( NULL);

   buf = mulle_malloc( size);
   if( ! buf)
   {
      close( fd);
      return( NULL);
   }

   read( fd, buf, size);
   close( fd);

   *p_size = size;
   return( buf);
}



static void  linux_argc_argv_set_arguments( struct argc_argv  *info,
                                            char *s,
                                            size_t length)
{
   char   *p;
   char   **q;
   char   **q_sentinel;
   char   *sentinel;
   int    argc;

   info->argc    = 0;
   info->argv    = NULL;

   sentinel = &s[ length];
   if( s == sentinel)
      return;

   argc = 0;
   for( p = s; p < sentinel; p++)
      if( ! *p)
         argc++;

   assert( argc && ! p[ -1]);

   info->argv = mulle_calloc( argc, sizeof( char *));
   info->argc = argc;

   q          = info->argv;
   q_sentinel = &q[ argc];
   p          = s;

   while( q < q_sentinel && p < sentinel)
   {
      *q++ = p;
      p    = &p[ strlen( p) + 1];
   }
}


static void   unlazyArguments( NSProcessInfo *self)
{
   struct argc_argv   info;
   char               *arguments;
   size_t             size;

   arguments = get_arguments( &size);
   if( ! arguments)
      MulleObjCThrowInternalInconsistencyException( @"can't get argc/argv from /proc/self/cmdline (%d)", errno);

   linux_argc_argv_set_arguments( &info, arguments, size);

   // in cosmopolitan we got ape in front, which we gotta lop off
#ifdef __MULLE_COSMOPOLITAN__
   self->_arguments = [NSArray _newWithArgc:info.argc -1
                                       argv:info.argv + 1];
#else
   self->_arguments = [NSArray _newWithArgc:info.argc
                                       argv:info.argv];
#endif
   mulle_free( info.argv);
   mulle_free( arguments);
}


- (NSArray *) arguments
{
   if( ! _arguments)
      unlazyArguments( self);
   return( _arguments);
}


#pragma mark - Environment

static void   unlazyEnvironment( NSProcessInfo *self)
{
   extern char   **environ;

   self->_environment = [NSDictionary _newWithEnvironment:environ];
}


- (NSDictionary *) environment
{
   if( ! _environment)
      unlazyEnvironment( self);
   return( _environment);
}


#pragma mark - Executable Path

static void   unlazyExecutablePath( NSProcessInfo *self)
{
   char      buf[ PATH_MAX + 1];
   ssize_t   len;

   len = readlink("/proc/self/exe", buf, PATH_MAX);
   if( len == (size_t) -1)
      MulleObjCThrowInternalInconsistencyException( @"can't get executable path from /proc/self/exe (%d)", errno);

   self->_executablePath = [[NSString alloc] initWithCString:buf
                                                      length:len];
}


- (NSString *) _executablePath
{
   if( ! (id) _executablePath)
      unlazyExecutablePath( self);
   return( _executablePath);
}


#pragma mark - Host and OS

- (NSString *) hostName
{
   return( @"localhost");
}


- (NSString *) operatingSystemName
{
   return( @"Linux");
}


- (NSUInteger) operatingSystem
{
   return( NSLinuxOperatingSystem);
}


#pragma mark - processName

// GETPROGNAME(3bsd)
// we just return the name of the executable
- (NSString *) processName
{
   NSString   *s;

   s = [self _executablePath];
   s = [s lastPathComponent];
   return( s);
}


- (void) setProcessName:(NSString *) name
{
   // we aren't doing this on Linux as setprogname is not native and we
   // want to avoid linking against bsd-compat
}

@end

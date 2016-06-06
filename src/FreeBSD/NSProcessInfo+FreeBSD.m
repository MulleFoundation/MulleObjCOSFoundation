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
#import "MulleObjCPosixFoundation.h"


// other files in this library

// other libraries of MulleObjCPosixFoundation
#import "NSArray+PosixPrivate.h"

// std-c and dependencies
#include <sys/types.h>
#include <sys/sysctl.h>


@implementation NSProcessInfo( FreeBSD)


///* The MIT License
// *
// * Copyright (C) 2007 Chris Miles
// *
// * Copyright (C) 2009 Erick Tryzelaar
// *
// *
// * Permission is hereby granted, free of charge, to any person obtaining a
// * copy of this software and associated documentation files (the "Software"),
// * to deal in the Software without restriction, including without limitation
// * the rights to use, copy, modify, merge, publish, distribute, sublicense,
// * and/or sell copies of the Software, and to permit persons to whom the
// * Software is furnished to do so, subject to the following conditions:
// *
// * The above copyright notice and this permission notice shall be included in
// * all copies or substantial portions of the Software.
// *
// * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// * DEALINGS IN THE SOFTWARE.
// */
//
//
///** Find the executable, argument list and environment
// *
// * This will also fill in the command attribute.
// *
// * The sysctl calls here don't use a wrapper as in darwin_prcesstable.c since
// * they know the size of the returned structure already.
// *
// * The layout of the raw argument space is documented in start.s, which is
// * part of the Csu project.  In summary, it looks like:
// *
// * XXX: This layout does not match whith what the code does.  The code seems
// * to think exec_path is in between the first argc and arg[0], also the data
// * returned by ssyctl() seems to be starting at the first argc according to
// * the code.
// *
// * /---------------\ 0x00000000
// * :               :
// * :               :
// * |---------------|
// * | argc          |
// * |---------------|
// * | arg[0]        |
// * |---------------|
// * :               :
// * :               :
// * |---------------|
// * | arg[argc - 1] |
// * |---------------|
// * | 0             |
// * |---------------|
// * | env[0]        |
// * |---------------|
// * :               :
// * :               :
// * |---------------|
// * | env[n]        |
// * |---------------|
// * | 0             |
// * |---------------| <-- Beginning of data returned by sysctl() is here.
// * | argc          |
// * |---------------|
// * | exec_path     |
// * |:::::::::::::::|
// * |               |
// * | String area.  |
// * |               |
// * |---------------| <-- Top of stack.
// * :               :
// * :               :
// * \---------------/ 0xffffffff
// */
typedef struct
{
   int      argc;
   char     **argv;
   char     **env;
} argv_and_environ;


static void  free_argv( int argc, char **argv)
{
   // free argv
   while( argc)
      mulle_free( argv[ --argc]);
   mulle_free( argv);
}


static void  free_env( char **env)
{
   char   **p;
   
   if( p = env)
      while( *p)
         mulle_free( *p++);
   mulle_free( env);
}


static inline void  free_argv_and_env( argv_and_environ *info)
{
   free_argv( info->argc, info->argv);
   free_env( info->env);
}


static inline int   copy_argc_argv( int argc, char **argv, argv_and_environ *info)
{
   char   *s;
   int    i;
   
   info->argv = (char **) calloc( sizeof( char *) * argc, 1);
   if( ! info->argv)
      return( -1);
      
   for( i = 0; i < argc; i++)
   {
      s = mulle_strdup( argv[ i]);
      if( ! s)
         return( -1);
      
      info->argv[ info->argc++] = s;
   }
   return( 0);
}


static inline int   copy_env( char **environment, argv_and_environ *info)
{
   int    n_env;
   int    i;
   char   *s;
   
   /* The environment, we figure out how many entries there are first */
   n_env = 0;
   if( environment)
      for( ; environment[ n_env]; n_env++);

   info->env = mulle_calloc( sizeof( char *) * (n_env + 1), 1);
   if( ! info->env)
      return( -1);
      
   for( i = 0; i < n_env; i++)
   {
      s = mulle_strdup( environment[ i]);
      if( ! s)
         return( -1);
      info->env[ i] = s;
   }
   
   return( 0);
}



//
// -1 : memory error
// -2 : parse error
//
static int  parse_stack_frame( char *buf, size_t size, int n_args, argv_and_environ *info)
{
   char     *p;
   char     *s;
   char     *sentinel;
   size_t   env_size;
   int      i;
   int      n_env;
   
   assert( ! info->argc);
   assert( info->argv);
   assert( ! info->env);
   
   sentinel = &buf[ size];
   p        = buf;
   
   // need some executable here
   if( ! p)
      return( -2);
   
   s = strdup( p);
   p = &p[ strlen( p) + 1];
   if( ! s)
      return( -1);
   
   info->argv[ info->argc++] = s;
   
   // really needed ??? probably because of alignment
   while( p < sentinel && ! *p)
      ++p;
   
   //
   // now we are in "string area"
   //
   while( info->argc <= n_args)
   {
      if( p >= sentinel)
         return( -2);
      
      s = strdup( p);
      p = &p[ strlen( p) + 1];
      if( ! s)
         return( -1);
      
      info->argv[ info->argc++] = s;
   }
   
   /* The environment, we figure out how many entries there are first */
   s = p;
   for( n_env = 0; s < sentinel; n_env++)
      s = &s[ strlen( s) + 1];

   info->env = malloc( sizeof( char *) * (n_env + 1));
   info->env[ n_env] = 0;
   
   for( i = 0; i < n_env; i++)
   {
      s = strdup( p);
      p = &p[ strlen( p) + 1];
      if( ! s)
         return( -1);
      
      info->env[ i] = s;
   }
   return( 0);
}


static int   _NSGetArgcArgvEnviron( int *o_argc, char ***o_argv, char ***o_env)
{
   argv_and_environ   info;
   char     *buf;
   size_t   size;
   int      mib[3];
   int      argmax;
   int      n_args;
   int      rval;
   
   rval = -1;  // generic system error
   
   *o_argc = 0;
   *o_argv = NULL;
   if( o_env)
      *o_env = NULL;
   
   /* Get the maximum process arguments size. */
   mib[ 0] = CTL_KERN;
   mib[ 1] = KERN_ARGMAX;
   
   size = sizeof( argmax);
   if( sysctl( mib, 2, &argmax, &size, NULL, 0) == -1) 
      return( -1);
   
   /* Allocate space for the arguments. */
   buf = malloc( argmax);
   if( ! buf)
      return( -1);
   
   /* Make a sysctl() call to get the raw argument space of the process. */
   mib[ 0] = CTL_KERN;
   mib[ 1] = KERN_PROCARGS2;
   mib[ 2] = getpid();
   
   size = (size_t) argmax;
   if( sysctl( mib, 3, buf, &size, NULL, 0) == -1) 
      goto fail_and_bail;
   
   buf = realloc( buf, size);
   if( ! buf)
      return( -1);

   //
   // grab n_args off 
   //
   memcpy( &n_args, buf, sizeof( n_args));
   
   info.argc = 0;
   info.env  = 0;
   info.argv = (char **) malloc( sizeof( char *) * (n_args + 1));
   if( ! info.argv)
      goto fail_and_bail;
   
   rval = parse_stack_frame( &buf[ sizeof( n_args)], size - sizeof( n_args), n_args, &info);
   
   if( ! rval)
   {
      *o_argc = info.argc;
      *o_argv = info.argv;
      if( o_env)
         *o_env = info.env;
      else
         free_env( &info);
   }
   else
      free_argv_and_env( &info);
   
fail_and_bail:
   free( buf);
   return( rval);
}



static void   unlazyArgumentsAndEnvironment( NSProcessInfo *self)
{
   int    argc;
   char   **argv;
   char   **env;
   int    rval;
   
   if( rval = _NSGetArgcArgvEnviron( &argc, (char ***) &argv, &env))
      MulleObjCThrowInternalInconsistencyException( @"can't get argc/argv from sysctl (%d,%d)", rval, errno);
   
   self->_arguments  = [NSArray _newWithArgc:argc
                                  argvNoCopy:argv];
   self->_environment = [NSDictionary _newWithEnvironmentNoCopy:env];
}


- (NSArray *) arguments
{
   if( ! _arguments)
      unlazyArgumentsAndEnvironment( self);
   return( _arguments);
}


- (NSDictionary *) environment
{
   if( ! _environment)
      unlazyArgumentsAndEnvironment( self);
   return( _environment);
}

@end
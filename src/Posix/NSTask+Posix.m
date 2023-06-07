//
//  NSTask+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 06.04.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#define _XOPEN_SOURCE 700
#define _DEFAULT_SOURCE

#import "import-private.h"

#import <MulleObjCOSBaseFoundation/NSTask-Private.h>

// other libraries of MulleObjCPosixFoundation
#import "NSError+Posix.h"

// std-c and dependencies
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>


#define USE_FORK
// #define DEBUG_TASK


#ifdef USE_FORK
# define vfork  fork
# undef vfork_name
# define vfork_name  "fork"
#else
# undef vfork_name
# define vfork_name  "vfork"
#endif



@implementation NSTask (Posix)


// static void   do_the_dup( int fd, id handle)
// {
//    int  other_fd;
// 
//    if( ! handle)
//       return;
// 
//    //
//    // Example: child stdin(0), pipe is [0/1] [read/write]
//    // so parent "writes" into pipe[ 1] for child( 0) via pipe[ 0]
//    // Ergo: child gets pipe[ 0] dupped
//    //
//    // Other example: child stdout(1), pipe is [0/1] [read/write]
//    // so we "read" from pipe[ 0], where child( 1) writes into via pipe[ 1]
//    // Ergo: child gets pipe[ 1] dupped
//    //
// 
//    other_fd = (! fd)
//               ? [handle _fileDescriptorForReading]
//               : [handle _fileDescriptorForWriting];
// 
//    assert( ! fd || other_fd);
// 
//    if( other_fd != fd)
//    {
// #ifdef DEBUG_TASK
//       fprintf( stderr, "task %d dup %d -> %d\n", (int) getpid(), other_fd, fd);
// #endif
//       close( fd);
//       dup( other_fd);
//    }
// }


//
// Because the launchPath will be used to exec another executable immediately
// vfork is the sensible choice. It also stops the parent process until
// execve is run, which seems kinda desired behaviour by itself
//
// TODO: create a -fork co-process functionality without a launchPath ?
//
- (void) launch
{
   pid_t        pid;
   char         **envp;
   char         *path;
   NSUInteger   argc;
   NSUInteger   i;
   int          fds[ 2][ 3];
   int          rval;

   MulleObjCSetPosixErrorDomain();

   //
   // path is autoreleased and argv is on the stack
   // is this a problem ?
   // if we "vfork" then parent is suspended until execve (no problem)
   // if we "fork" then everything should be copied into the fork (no problem)
   //
   path = [_launchPath fileSystemRepresentation];
   argc = [_arguments count];
   envp = [NSTask _environment];

   //
   // Objective-C is NOT a good idea inside the vfork child.
   // It's not a problem though after fork.
   //
   fds[ 0][ 0] = [_standardInput  _fileDescriptorForWriting];
   fds[ 0][ 1] = [_standardOutput _fileDescriptorForReading];
   fds[ 0][ 2] = [_standardError  _fileDescriptorForReading];

   fds[ 1][ 0] = [_standardInput  _fileDescriptorForReading];
   fds[ 1][ 1] = [_standardOutput _fileDescriptorForWriting];
   fds[ 1][ 2] = [_standardError  _fileDescriptorForWriting];

   for( i = 0; i < 3; i++)
   {
      assert( ! fds[ 0][ i] || fds[ 0][ i] > 2);
      assert( ! fds[ 1][ i] || fds[ 1][ i] > 2);
   }

   {
      char  *argv[ argc + 2];

      assert( sizeof( id) == sizeof( char *));

      [_arguments getObjects:(id *) &argv[ 1]];
      for( i = 1; i <= argc; i++)
         argv[ i] = (char *) [(id) argv[ i] cString];
      assert( i < argc + 2);
      argv[ i] = 0;
      argv[ 0] = path;  // [[_launchPath lastPathComponent] cString];

#ifdef DEBUG_TASK
      fprintf( stderr, "task %d starts\n", (int) getpid());
#endif
      _status = _NSTaskIsPresumablyRunning;

#ifdef DEBUG_TASK
      fprintf( stderr, "task %d %s\n", (int) getpid(), vfork_name);
#endif
#ifdef DEBUG_TASK
      {
         char   *sep = "";

         fprintf( stderr, "task %d %s with \"%s\" (", (int) getpid(), vfork_name, path);
         for( i = 0; i <= argc; i++)
         {
            fprintf( stderr, "%s%s", sep, argv[ i]);
            sep = " ";
         }
         fprintf( stderr, ")\n");
      }
#endif

      if( ! (pid = vfork()))
      {
         // output this first before stderr gets redirected
#ifdef DEBUG_TASK
         fprintf( stderr, "task %d closes / dups handles\n", (int) getpid());
#endif
         for( i = 0; i < 3; i++)
         {
            if( fds[ 0][ i])
            {
               rval = close( fds[ 0][ i]);
               if( rval == -1)
               {
                  fprintf( stderr, "task %d could not close filehandle %d properly (%d:%s)\n", (int) getpid(), fds[ 0][ i], errno, strerror( errno));
                  _exit( 1);
               }
               rval = close( i);
               if( rval == -1)
               {
                  fprintf( stderr, "task %d could not close filehandle %d properly (%d:%s)\n", (int) getpid(), (int) i, errno, strerror( errno));
                  _exit( 1);
               }
               rval = dup( fds[ 1][ i]);
               if( rval == -1)
               {
                  fprintf( stderr, "task %d could not dup filehandle %d properly (%d:%s)\n", (int) getpid(), fds[ 1][ i], errno, strerror( errno));
                  _exit( 1);
               }
            }
         }

         execve( path, (char **) argv, envp);

         // oughta be back in "parent" here in vfork case or ?
         _status = _NSTaskHasFailedLaunching;
         // error
         fprintf( stderr, "task %d could not launch %s (%d:%s)\n", (int) getpid(), path, errno, strerror( errno));
         _exit( 1);
      }

      if( pid < 0)
         MulleObjCThrowInvalidArgumentException( @"%@ could not %s", self, vfork_name);
   }
   _pid = pid;

#ifdef DEBUG_TASK
   fprintf( stderr, "task %d %s -> %d\n", (int) getpid(), vfork_name, (int) pid);
#endif

#ifdef DEBUG_TASK
   fprintf( stderr, "task %d closes handles\n", (int) getpid());
#endif

   for( i = 0; i < 3; i++)
      if( fds[ 1][ i])
      {
         rval = close( fds[ 1][ i]);
         if( rval == -1)
            MulleObjCThrowInvalidArgumentException( @"parent task %d could not close filehandle %d properly (%s)\n", (int) getpid(), fds[ 1][ i], strerror( errno));
      }
}


- (BOOL) mulleCheckIfRunning
{
   switch( _status)
   {
   default :
      MulleObjCThrowInternalInconsistencyException( @"task not started");
      break;

   case _NSTaskIsPresumablyRunning :
      NSParameterAssert( _pid);
#ifdef DEBUG_TASK
      fprintf( stderr, "task %d checks for %d\n", (int) getpid(), (int) _pid);
#endif
      if( waitpid( _pid, &_terminationStatus, WNOHANG) == -1)
         return( YES);  // guess
      if( ! WIFEXITED( _terminationStatus))
         return( YES);
#ifdef DEBUG_TASK
      fprintf( stderr, "task %d considers %d terminated with %d\n",
                       (int) getpid(),
                       (int) _pid,
                       (int) _terminationStatus);
#endif
      _status = _NSTaskHasTerminated;
      // fall thru

   case _NSTaskHasFailedLaunching :
   case _NSTaskHasTerminated      :
      break;
   }
   return( NO);
}


- (void) waitUntilExit
{
   switch( _status)
   {
   default :
      MulleObjCThrowInternalInconsistencyException( @"task not started");
      break;

   case _NSTaskIsPresumablyRunning :
      NSParameterAssert( _pid);
#ifdef DEBUG_TASK
      fprintf( stderr, "task %d waits for %d\n", (int) getpid(), (int) _pid);
#endif
      if( waitpid( _pid, &_terminationStatus, 0) == -1)
         MulleObjCThrowErrnoException(  @"waitpid failed");
#ifdef DEBUG_TASK
      fprintf( stderr, "task %d considers %d terminated with %d\n",
                       (int) getpid(),
                       (int) _pid,
                       (int) _terminationStatus);
#endif
      _status = _NSTaskHasTerminated;

   case _NSTaskHasFailedLaunching :
   case _NSTaskHasTerminated      :
      break;
   }
}

@end

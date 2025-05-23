//
//  NSData+Posix.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 27.03.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "import-private.h"

#import <MulleObjCOSBaseFoundation/NSPageAllocation-Private.h>

#import "NSError+Posix.h"

// std-c and dependencies
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>


@implementation NSData( Posix)


// could be anywhere
// TODO: use mulle_mmap_get_system_pagesize
+ (void) load
{
   _MulleObjCSetPageSize( sysconf(_SC_PAGESIZE));
}


static struct mulle_data  slurp_data_of_pipe( int fd, struct mulle_allocator *allocator)
{
   char                     *buf;
   ssize_t                  actual_len;
   struct mulle_data        data;

   mulle_buffer_do_allocator( buffer, allocator)
   {
      for(;;)
      {
         buf        = mulle_buffer_guarantee( buffer, 0x1000);
         actual_len = read( fd, buf, 0x1000);
         if( actual_len == 0)
         {
            data = mulle_buffer_extract_data( buffer);
            // EOF
            break;
         }
         if( actual_len == -1)
         {
            // some error happened
            data = mulle_data_make_empty();
            break;
         }
         mulle_buffer_advance( buffer, actual_len);
      }
   }

   return( data);
}


- (instancetype) initWithContentsOfFile:(NSString *) path
{
   struct mulle_allocator   *allocator;
   struct stat              info;
   char                     *buf;
   char                     *filename;
   ssize_t                  actual_len;
   ssize_t                  initial_len;
   ssize_t                  len;
   int                      fd;
   struct mulle_data        data;

   MulleObjCSetPosixErrorDomain();

   allocator = MulleObjCInstanceGetAllocator( self);
   filename  = [path fileSystemRepresentation];

   // MEMO: remember that this has to be able to deal with pipes
   fd = open( filename, O_RDONLY);
   if( fd == -1)
   {
      [self release];
      return( nil);
   }

   // because we want to support pipes, we need to fstat here :/
   if( fstat( fd, &info) == -1)
      goto fail_close;

   if( info.st_mode & S_IFDIR)
   {
      errno = EISDIR;
      goto fail_close;
   }


   if( info.st_mode & S_IFIFO)
   {
      data       = slurp_data_of_pipe( fd, allocator);
      if( ! data.bytes)
         goto fail_close;

      buf        = data.bytes;
      actual_len = data.length;
   }
   else
   {
      //
      // speculatively read 4KB, for small files that's plenty, and we
      // can do the minimum syscalls. Also its likely a "sector" as well
      // as a memory page (could use PAGSIZE here maybe)
      //
      initial_len = 0x1000;
      buf         = mulle_allocator_malloc( allocator, initial_len);
      actual_len  = read( fd, buf, initial_len);
      if( actual_len == -1)
         goto fail_free_close;

      len = initial_len;
      if( actual_len == initial_len)
      {
         // warning this may have a 2 GB problem is off_t is 64 bit
         // and ssize_t is 31 bit
         len = (size_t) info.st_size;
         if( (off_t) len != info.st_size)
         {
            errno = EFBIG;
            goto fail_free_close;
         }

         if( len != actual_len)
         {
            buf = mulle_allocator_realloc( allocator, buf, len);

            // The system guarantees to read the number of bytes requested
            // if the descriptor references a normal file that has that
            // many bytes left before the end-of-file, but in no other case
            actual_len = read( fd, &buf[ actual_len], len - actual_len);
            if( actual_len == -1)
               goto fail_free_close;

            actual_len += initial_len;
         }
      }

      if( actual_len != len)
         buf = _mulle_allocator_realloc_strict( allocator, buf, actual_len);

   }
   close( fd);

   // we can read an empty, file still need a data to proceed
   return( [self mulleInitWithBytesNoCopy:buf
                                   length:actual_len
                                allocator:allocator]);

fail_free_close:
   mulle_allocator_free( allocator, buf);
fail_close:
   close( fd);
   [self release];
   return( nil);
}


- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag
{
   NSString            *new_path;
   ssize_t             written;
   int                 fd;
   int                 rval;
   char                *c_path;
   char                *c_new;
   char                *c_old;
   struct mulle_data   data;

   // TODO: need to set POSIX errno domain here
   NSParameterAssert( [path length]);

   MulleObjCSetPosixErrorDomain();

   new_path = flag ? [path stringByAppendingString:@"~"] : path;
   c_path   = [new_path fileSystemRepresentation];

   fd = open( c_path, O_WRONLY|O_CREAT|O_TRUNC, 0666);
   if( fd == -1)
      return( NO);

   data = [self mulleCData];
   for(; data.length;)
   {
      written = write( fd, data.bytes, data.length);
      if( written == -1)
      {
         close( fd);
         return( NO);
      }
      data.bytes   = &((char *) data.bytes)[ written];
      data.length -= written;
   }
   close( fd);

   if( ! flag)
      return( YES);

   c_new = [path fileSystemRepresentation];
   c_old = c_path;

   rval = unlink( c_new);
   if( rval)
   {
      if( errno != ENOENT)
      {
         unlink( c_old); // clean up
         return( NO);
      }
   }

   rval = rename( c_old, c_new);
   if( rval)
   {
      NSLog( @"file \"%s\" not renamed to \"%s\" : %s\n", c_old, c_new, strerror( errno));
      return( NO);
   }
   return( YES);
}


- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag
               error:(NSError **) p_error
{
   if( [self writeToFile:path
              atomically:flag])
      return( YES);

   if( p_error)
      *p_error = MulleObjCExtractError();
   return( NO);
}

@end

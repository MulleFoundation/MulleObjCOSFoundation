// stolen from https://www.geeksforgeeks.org/c-program-demonstrate-fork-and-pipe/

// C program to demonstrate use of fork() and pipe()
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <pthread.h>
#include <errno.h>


#define EXECUTABLE   "/bin/cat"
//#define EXECUTABLE   "/home/nat/bin/unix-cat"
//#define EXECUTABLE   "/bin/true"


struct write_thread_info
{
   int     fd;
   char    *bytes;
   size_t  length;
};


void  *write_data_threaded( struct write_thread_info *info)
{
   ssize_t   len;
   char      *bytes;
   size_t    length;

   bytes  = info->bytes;
   length = info->length;
   fprintf( stderr, "parent write\n");
   for(;;)
   {
      len = write( info->fd, bytes, length);
      fprintf( stderr, "parent wrote (%lld of %lld)\n", (long long) len, (long long) info->length);
      if( len == 0)
         break;
      if( len == -1)
      {
         switch( errno)
         {
         case EINTR :
            continue;

         default :
            perror( "write:");
            exit( 1);

         case EPIPE  :
            fprintf( stderr, "broken pipe\n");
            break;

         case EAGAIN :
            break;
         }
         break;
      }
      bytes   = &bytes[ len];
      length -= len;
   }

   fprintf( stderr, "parent close write\n");
   close( info->fd);
   return( NULL);
}


int main()
{
    // We use two pipes
    // First pipe to send input string from parent
    // Second pipe to send concatenated string from child

   int                       fd1[2]; // Used to store two ends of first pipe
   int                       fd2[2]; // Used to store two ends of second pipe
   static char               random[ 1024 * 1024];
   ssize_t                   len;
   pthread_t                 write_thread;
   struct write_thread_info  write_thread_info;

   memset( random, 'V', sizeof( random));

   pid_t p;

   if (pipe(fd1) == -1) {
      fprintf(stderr, "Pipe Failed");
      return 1;
   }
   if (pipe(fd2) == -1) {
      fprintf(stderr, "Pipe Failed");
      return 1;
   }

   p = fork();
   if (p < 0) {
      fprintf(stderr, "fork Failed");
      return 1;
   }

    // Parent process
   if( ! p)
   {
      close(fd1[1]); // Close writing end of first pipe
      close(fd2[0]); // Close reading end of second pipe

      close( 0);
      dup( fd1[0]);
      close( 1);
      dup( fd2[1]);
      execl( EXECUTABLE, EXECUTABLE, NULL);

      exit(1);
   }

   close( fd1[0]); // Close reading end of first pipe
   close( fd2[1]); // Close writing end of second pipe

   // Write input string and close writing end of first
   // pipe.
   signal( SIGPIPE, SIG_IGN);

   write_thread_info.fd     = fd1[ 1];
   write_thread_info.bytes  = random;
   write_thread_info.length = sizeof( random);

   pthread_create( &write_thread,
                   NULL,
                   (void *(*)( void *)) write_data_threaded,
                   &write_thread_info);

   fprintf( stderr, "parent read\n");
   for(;;)
   {
      len = read( fd2[ 0], random, sizeof( random));
      fprintf( stderr, "parent close read (%lld)\n", (long long) len);
      if( ! len)
          break;
      printf("%.*s\n", 256, random);
   }
   close(fd2[0]);

   // Wait for child to send a string
   fprintf( stderr, "parent wait\n");
   wait(NULL);

   pthread_join( write_thread, NULL);

   fprintf( stderr, "parent done\n");
   return( 0);
}

#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

#include <stdio.h>

#ifdef _WIN32
# include <io.h>
# define dup    _dup
# define dup2   _dup2
# define fileno _fileno
#else
# include <unistd.h>
#endif


static int   savedError;

static void   captureBegin( void)
{
   savedError = dup( fileno( stderr));
   freopen( "nslog-output.txt", "w", stderr);
}


static void   captureEnd( void)
{
   fflush( stderr);
   dup2( savedError, fileno( stderr));
   close( savedError);
}


static void   logWithVaList( NSString *format, ...)
{
   va_list   args;

   va_start( args, format);
   NSLogv( format, args);
   va_end( args);
}


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSFileManager   *fileManager;
   NSString        *content;

   fileManager = [NSFileManager defaultManager];
   [fileManager removeItemAtPath:@"nslog-output.txt" error:NULL];

   captureBegin();
   NSLog( @"value=%@ %d", @"x", 7);
   logWithVaList( @"v=%s", "abc");
   captureEnd();

   content = [NSString stringWithContentsOfFile:@"nslog-output.txt"];
   show( @"content-non-nil", content != nil);
   show( @"contains-object",
         [content rangeOfString:@"value=x 7"].location != NSNotFound);
   show( @"contains-va",
         [content rangeOfString:@"v=abc"].location != NSNotFound);

   [fileManager removeItemAtPath:@"nslog-output.txt" error:NULL];

   return( 0);
}

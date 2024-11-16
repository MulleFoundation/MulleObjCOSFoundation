/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSTask+System.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, __MyCompanyName__
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "NSTask+System.h"

// other files in this library
#import "NSPipe.h"
#import "NSFileHandle.h"
#import "NSFileManager.h"
#import "NSProcessInfo.h"
#import "NSString+CString.h"
#import "NSString+OSBase.h"

#include <signal.h>

// #define DEBUG_IO


NSString   *NSTaskExceptionKey            = @"exception";
NSString   *NSTaskTerminationStatusKey    = @"terminationStatus";
NSString   *NSTaskStandardOutputDataKey   = @"standardOutputData";
NSString   *NSTaskStandardOutputStringKey = @"standardOutputString";
NSString   *NSTaskStandardErrorDataKey    = @"standardErrorData";
NSString   *NSTaskStandardErrorStringKey  = @"standardErrorString";


@implementation NSFileManager( System)

- (NSString *) mulleFindExecutable:(NSString *) name
                            inPATH:(NSString *) envPATH
{
   NSString   *executablePath;
   NSString   *absolute;

   assert( ! [name isAbsolutePath]);

   if( ! envPATH)
      envPATH = [[[NSProcessInfo processInfo] environment] objectForKey:@"PATH"];

   for( executablePath in [envPATH componentsSeparatedByString:@":"])
   {
      absolute = [executablePath stringByAppendingPathComponent:name];
      if( [self isExecutableFileAtPath:absolute])
         return( absolute);
   }
   return( nil);
}


@end


struct thread_info
{
   NSThread      *thread;
   NSFileHandle  *fileHandle;
   NSData        *data;
};


static int   writeFileHandleDataAndClose( NSThread *thread, void *_info)
{
   struct thread_info *info = _info;

   [info->fileHandle mulleGainAccess];
   [info->data mulleGainAccess];

#ifdef DEBUG_IO
   fprintf( stderr, "write data\n");
#endif
   [info->fileHandle writeData:info->data];
#ifdef DEBUG_IO
   fprintf( stderr, "close write\n");
#endif
   [info->fileHandle closeFile];
#ifdef DEBUG_IO
   fprintf( stderr, "end write thread\n");
#endif
   [info->data autorelease];
   [info->fileHandle autorelease];
   return( 0);
}


static int   readFileHandleData( NSThread *thread, void *_info)
{
   struct thread_info *info = _info;

   [info->fileHandle mulleGainAccess];

#ifdef DEBUG_IO
   fprintf( stderr, "read err data\n");
#endif
   info->data = [[info->fileHandle readDataToEndOfFile] retain];
#ifdef DEBUG_IO
   fprintf( stderr, "end read err thread\n");
#endif
   [info->fileHandle autorelease];
   [info->data mulleRelinquishAccess];

   return( 0);
}

// @selector( mulleDataSystemCallWithArguments:environment:workingDirectory:standardInputData:options:)
@implementation NSTask( System)

+ (NSDictionary *) mulleDataSystemCallWithArguments:(NSArray *) argv
                                        environment:(NSDictionary *) environment
                                   workingDirectory:(NSString *) dir
                                  standardInputData:(NSData *) inputData
                                            options:(NSTaskSystemOptions) options
{
   int                  rval;
   NSArray              *arguments;
   NSFileHandle         *file;
   NSInteger            argc;
   NSPipe               *stdoutPipe;
   NSPipe               *stdinPipe;
   NSPipe               *stderrPipe;
   NSString             *absolute;
   NSString             *executablePath;
   NSString             *envPATH;
   NSTask               *task;
   NSMutableDictionary  *merged;
   NSFileManager        *fileManager;
   void                 (*previous_handler)(int);
   id                   exception;
   struct thread_info   info[ 3] = { 0 };

   argc = [argv count];
   if( ! argc)
      return( @{ NSTaskExceptionKey: [NSException exceptionWithName:NSInvalidArgumentException
                                                             reason:@"empty arguments"
                                                           userInfo:nil] });

   exception = 0;
   rval      = -1;

   @autoreleasepool
   {
     // signal is too POSIX specific (move to NSTask+Posix)
      previous_handler = signal( SIGPIPE, SIG_IGN);
      @try
      {
         task       = [[NSTask new] autorelease];
         stdinPipe  = (options & NSTaskSystemSendStandardInput)     ? [NSPipe pipe] : nil;
         stdoutPipe = (options & NSTaskSystemReceiveStandardOutput) ? [NSPipe pipe] : nil;
         stderrPipe = (options & NSTaskSystemReceiveStandardError)  ? [NSPipe pipe] : nil;

         executablePath = [argv objectAtIndex:0];
         envPATH        = nil;

         if( environment)
         {
            merged = [NSMutableDictionary dictionaryWithDictionary:[[NSProcessInfo processInfo] environment]];
            [merged addEntriesFromDictionary:environment];
            [task setEnvironment:merged];
            mulle_fprintf( stderr, "%merged: %@", merged);
            envPATH = [merged :@"PATH"];
         }

         if( ! [executablePath isAbsolutePath])
         {
            fileManager = [NSFileManager defaultManager];
            absolute    = [fileManager mulleFindExecutable:executablePath
                                                    inPATH:envPATH];
         }
         else
            absolute = executablePath;

         if( ! absolute)
            [NSException raise:NSInvalidArgumentException
               format:@"executable \"%@\" must be absolute or in PATH", executablePath];
         [task setLaunchPath:absolute];

         if( [dir length])
            [task setCurrentDirectoryPath:dir];

         arguments = [argv subarrayWithRange:NSRangeMake( 1, argc - 1)];
         [task setArguments:arguments];
         [task setStandardInput:stdinPipe];
         [task setStandardOutput:stdoutPipe];
         [task setStandardError:stderrPipe];
         [task launch];

         if( stdinPipe)
         {
            info[ 0].data       = [inputData copy];
            [info[0].data mulleRelinquishAccess];

            info[ 0].fileHandle = [[stdinPipe fileHandleForWriting] retain];
            [info[0].fileHandle mulleRelinquishAccess];

            info[ 0].thread     = [[[NSThread alloc] mulleInitWithFunction:writeFileHandleDataAndClose
                                                                  argument:&info[ 0]] autorelease];
            [info[ 0].thread mulleStart];
         }

   //         info[ 1].data       = nil
   //         info[ 1].fileHandle = [[stdinPipe fileHandleForReading] retain]
   //         info[ 1].thread     = [NSThread mulleInitWithFunction:readFileHandleData
   //                                                      argument:&info[ 1]];
   //         [info[ 1].thread mulleStartUndetached];

         if( stderrPipe)
         {
            info[ 2].data       = nil;
            info[ 2].fileHandle = [[stderrPipe fileHandleForReading] retain];
            [info[2].fileHandle mulleRelinquishAccess];
            info[ 2].thread     = [[[NSThread alloc] mulleInitWithFunction:readFileHandleData
                                                                  argument:&info[ 2]] autorelease];
            [info[ 2].thread mulleStart];
         }

         if( stdoutPipe)
         {
         // save a thread by running stdout reader in this thread
            file = [stdoutPipe fileHandleForReading];
#ifdef DEBUG_IO
            fprintf( stderr, "start read\n");
#endif
            info[ 1].data = [[file readDataToEndOfFile] retain];
#ifdef DEBUG_IO
            fprintf( stderr, "close read\n");
#endif
         }
#ifdef DEBUG_IO
         fprintf( stderr, "wait\n");
#endif
         [task waitUntilExit];
#ifdef DEBUG_IO
         fprintf( stderr, "join stderr\n");
#endif
         [info[ 2].thread mulleJoin];
         [info[ 2].data mulleGainAccess];
#ifdef DEBUG_IO
         fprintf( stderr, "join stdin\n");
#endif
         [info[ 0].thread mulleJoin];  // not really needed

         rval = [task terminationStatus];
      }
      @catch( id e)
      {
         exception = [e retain];
      }
      signal( SIGPIPE, previous_handler);
   }

   [info[ 1].data autorelease];
   [info[ 2].data autorelease];
   [exception autorelease];
   if( exception)
      return( @{ NSTaskExceptionKey: exception });

#ifdef DEBUG_IO
   if( rval)
      mulle_fprintf( stderr, "child exited with %d: \"%.*s\"\n",
                             rval,
                             [info[ 2].data length] > 512 ? 512 : [info[ 2].data length],
                             [info[ 2].data bytes]);
#endif

   return( @{
              NSTaskTerminationStatusKey : @( rval),
              NSTaskStandardOutputDataKey: (info[ 1].data ? info[ 1].data : [NSNull null]),
              NSTaskStandardErrorDataKey : (info[ 2].data ? info[ 2].data : [NSNull null])
            });
}


+ (NSDictionary *) mulleDataSystemCallWithArguments:(NSArray *) argv
                                   workingDirectory:(NSString *) dir
                                  standardInputData:(NSData *) inputData
                                            options:(NSTaskSystemOptions) options
{
   return( [self mulleDataSystemCallWithArguments:argv
                                      environment:nil
                                 workingDirectory:dir
                                standardInputData:inputData
                                         options:options]);
}


+ (NSDictionary *) mulleDataSystemCallWithArguments:(NSArray *) argv
                                        environment:(NSDictionary *) environment
                                  standardInputData:(NSData *) data
{
   return( [self mulleDataSystemCallWithArguments:argv
                                      environment:environment
                                 workingDirectory:nil
                                standardInputData:data
                                          options:NSTaskSystemOptionsDefault]);
}



+ (NSDictionary *) mulleDataSystemCallWithArguments:(NSArray *) argv
                                  standardInputData:(NSData *) data
{
   return( [self mulleDataSystemCallWithArguments:argv
                                      environment:nil
                                 workingDirectory:nil
                                standardInputData:data
                                          options:NSTaskSystemOptionsDefault]);
}




+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv
                                          environment:(NSDictionary *) environment
                                     workingDirectory:(NSString *) dir
                                  standardInputString:(NSString *) stdinString
                                              options:(NSTaskSystemOptions) options
{
   NSData         *data[ 2];
   NSData         *stdin;
   NSDictionary   *dictionary;
   NSException    *exception;
   NSNumber       *status;
   NSString       *string[ 2];
   NSUInteger     length;
   NSUInteger     original_length;
   unsigned int   i;
   char           *bytes;
   int            c;
   int            d;

   stdin      = [stdinString dataUsingEncoding:NSUTF8StringEncoding];
   dictionary = [self mulleDataSystemCallWithArguments:argv
                                           environment:environment
                                      workingDirectory:dir
                                     standardInputData:stdin
                                               options:options];
   assert( dictionary);

   exception = [dictionary :NSTaskExceptionKey];
   if( exception)
   {
      status     = @( -1);
      string[ 0] = @"";
      data[ 0]   = [NSData data];
      string[ 1] = [exception reason];
      data[ 1]   = [string[ 1] dataUsingEncoding:NSUTF8StringEncoding];
   }
   else
   {
      status = [dictionary :NSTaskTerminationStatusKey];
      for( i = 0; i < 2; i++)
      {
         data[ i] = [dictionary :((i == 0)
                                  ? NSTaskStandardOutputDataKey
                                  : NSTaskStandardErrorDataKey)];

         //
         // remove single trailing linefeed, if this is inconvenient use
         // the data methods
         //
         original_length = [data[ i] length];
         if( ! original_length)
         {
            string[ i] = @"";
            assert( data[ i]);
            continue;
         }

         bytes  = [data[ i] bytes];
         length = original_length;

         d = bytes[ length - 1];
         if( d == '\r' || d == '\n')
            if( ! --length)
            {
               string[ i] = @"";
               continue;
            }

         if( d == '\n')
         {
            c = bytes[ length - 1];
            if( c == '\r')
               if( ! --length)
               {
                  string[ i] = @"";
                  continue;
               }
         }

         string[ i] = [[[NSString alloc] initWithBytes:bytes
                                                length:length
                                              encoding:NSUTF8StringEncoding] autorelease];
      }
   }

   // we have data anyway, so plop it in as well
   return( @{
               NSTaskTerminationStatusKey    : status,
               NSTaskStandardOutputDataKey   : data[ 0],
               NSTaskStandardOutputStringKey : string[ 0],
               NSTaskStandardErrorDataKey    : data[ 1],
               NSTaskStandardErrorStringKey  : string[ 1]
            });
}


+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv
                                     workingDirectory:(NSString *) dir
                                  standardInputString:(NSString *) stdinString
                                              options:(NSTaskSystemOptions) options
{
   return( [self mulleStringSystemCallWithArguments:argv
                                        environment:nil
                                   workingDirectory:dir
                                standardInputString:stdinString
                                            options:options]);
}


+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv
                                          environment:(NSDictionary *) environment
                                  standardInputString:(NSString *) stdinString
{
   return( [self mulleStringSystemCallWithArguments:argv
                                        environment:environment
                                   workingDirectory:nil
                                standardInputString:stdinString
                                            options:NSTaskSystemOptionsDefault]);
}


+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv
                                          environment:(NSDictionary *) environment
{
   return( [self mulleStringSystemCallWithArguments:argv
                                        environment:environment
                                   workingDirectory:nil
                                standardInputString:nil
                                            options:NSTaskSystemOptionsDefault]);
}

+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv
                                  standardInputString:(NSString *) stdinString
{
   return( [self mulleStringSystemCallWithArguments:argv
                                        environment:nil
                                   workingDirectory:nil
                                standardInputString:stdinString
                                            options:NSTaskSystemOptionsDefault]);
}


+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv
{
   return( [self mulleStringSystemCallWithArguments:argv
                                        environment:nil
                                   workingDirectory:nil
                                standardInputString:nil
                                            options:NSTaskSystemOptionsDefault]);
}



/*
 * conveniences
 */

+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s
                                         workingDirectory:(NSString *) dir
                                              environment:(NSDictionary *) environment
                                      standardInputString:(NSString *) standardInputString
{
   NSArray  *argv;

   argv = [s mulleComponentsSeparatedByWhitespaceWithSingleAndDoubleQuoting];
   return( [self mulleStringSystemCallWithArguments:argv
                                        environment:environment
                                   workingDirectory:dir
                                standardInputString:standardInputString
                                            options:NSTaskSystemOptionsDefault]);
}



+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s
                                              environment:(NSDictionary *) environment
                                      standardInputString:(NSString *) standardInputString
{
   NSArray  *argv;

   argv = [s mulleComponentsSeparatedByWhitespaceWithSingleAndDoubleQuoting];
   return( [self mulleStringSystemCallWithArguments:argv
                                        environment:environment
                                   workingDirectory:nil
                                standardInputString:standardInputString
                                            options:NSTaskSystemOptionsDefault]);
}


+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s
                                      standardInputString:(NSString *) standardInputString
{
   NSArray  *argv;

   argv = [s mulleComponentsSeparatedByWhitespaceWithSingleAndDoubleQuoting];
   return( [self mulleStringSystemCallWithArguments:argv
                                        environment:nil
                                   workingDirectory:nil
                                standardInputString:standardInputString
                                            options:NSTaskSystemOptionsDefault]);
}


+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s
                                              environment:(NSDictionary *) environment
{
   NSArray  *argv;

   argv = [s mulleComponentsSeparatedByWhitespaceWithSingleAndDoubleQuoting];
   return( [self mulleStringSystemCallWithArguments:argv
                                        environment:environment
                                   workingDirectory:nil
                                standardInputString:nil
                                            options:NSTaskSystemOptionsDefault]);
}



+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s
{
   NSArray  *argv;

   argv = [s mulleComponentsSeparatedByWhitespaceWithSingleAndDoubleQuoting];
   return( [self mulleStringSystemCallWithArguments:argv
                                        environment:nil
                                   workingDirectory:nil
                                standardInputString:nil
                                            options:NSTaskSystemOptionsDefault]);
}


@end

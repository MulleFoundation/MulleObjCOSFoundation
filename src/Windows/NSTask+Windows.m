//
//  NSTask+Windows.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 23.01.26
//  Copyright © 2026 Mulle kybernetiK. All rights reserved.
//
#import "import-private.h"

#import <MulleObjCOSBaseFoundation/NSTask-Private.h>
#import "NSString+Windows.h"

// std-c and dependencies
#include <windows.h>
#include <mulle-utf/mulle-utf32.h>
#include <mulle-allocator/mulle-alloca.h>


@implementation NSTask( Windows)

//
// Build Windows command line string from launch path and arguments
// Returns NSString (not wchar_t*)
//
static NSString *_buildCommandLineString( NSString *launchPath, NSArray *arguments)
{
   NSMutableString   *cmdLine;
   NSUInteger        i, count;
   NSString          *arg;
   
   cmdLine = [NSMutableString stringWithCapacity:256];
   
   // Normalize forward slashes to backslashes in launch path
   launchPath = [launchPath mulleWindowsFileSystemString];

   // Add launch path (quoted if contains spaces)
   if( [launchPath rangeOfString:@" "].location != NSNotFound)
      [cmdLine appendFormat:@"\"%@\"", launchPath];
   else
      [cmdLine appendString:launchPath];
   
   // Add arguments
   count = [arguments count];
   for( i = 0; i < count; i++)
   {
      arg = [arguments objectAtIndex:i];
      [cmdLine appendString:@" "];
      
      // Quote if contains spaces
      if( [arg rangeOfString:@" "].location != NSNotFound)
         [cmdLine appendFormat:@"\"%@\"", arg];
      else
         [cmdLine appendString:arg];
   }
   
   return( cmdLine);
}


//
// Convert NSString to a malloc'd wchar_t* (UTF-16), caller must mulle_free
//
static wchar_t  *_createWideCString( NSString *string)
{
   NSUInteger   len;
   wchar_t      *result;
   unichar      *utf32;

   len = [string length];
   if( ! len)
      return( NULL);

   result = mulle_malloc( (len + 1) * sizeof( wchar_t));
   utf32  = mulle_malloc( len * sizeof( unichar));

   [string getCharacters:utf32 range:NSMakeRange( 0, len)];
   _mulle_utf32_convert_to_utf16( (mulle_utf32_t *) utf32, len, (mulle_utf16_t *) result);
   result[ len] = 0;

   mulle_free( utf32);
   return( result);
}


//
// Build a Windows environment block (double-null-terminated UTF-16 strings)
// from an NSDictionary. Caller must mulle_free the result.
// Format: KEY1=VALUE1\0KEY2=VALUE2\0\0
//
static wchar_t  *_buildEnvironmentBlock( NSDictionary *env)
{
   NSArray      *keys;
   NSUInteger   count, i, totalChars, entryLen, offset;
   wchar_t      *block;
   unichar      *utf32;
   NSString     *key, *value, *entry;

   keys  = [env allKeys];
   count = [keys count];

   if( ! count)
   {
      // empty environment: just a double null terminator
      block = mulle_malloc( 2 * sizeof( wchar_t));
      block[ 0] = 0;
      block[ 1] = 0;
      return( block);
   }

   // First pass: calculate total wchar_t count needed
   totalChars = 0;
   for( i = 0; i < count; i++)
   {
      key   = [keys objectAtIndex:i];
      value = [env objectForKey:key];
      // "key=value\0" -> key length + 1 (=) + value length + 1 (\0)
      totalChars += [key length] + 1 + [value length] + 1;
   }
   totalChars += 1; // final null terminator

   block = mulle_malloc( totalChars * sizeof( wchar_t));

   // Second pass: fill the block
   offset = 0;
   for( i = 0; i < count; i++)
   {
      key      = [keys objectAtIndex:i];
      value    = [env objectForKey:key];
      entry    = [NSString stringWithFormat:@"%@=%@", key, value];
      entryLen = [entry length];

      utf32 = mulle_malloc( entryLen * sizeof( unichar));
      [entry getCharacters:utf32 range:NSMakeRange( 0, entryLen)];
      _mulle_utf32_convert_to_utf16( (mulle_utf32_t *) utf32, entryLen, (mulle_utf16_t *) &block[ offset]);
      mulle_free( utf32);

      block[ offset + entryLen] = 0;
      offset += entryLen + 1;
   }
   block[ offset] = 0; // double null terminator

   return( block);
}


- (void) launch
{
   STARTUPINFOW          si;
   PROCESS_INFORMATION   pi;
   BOOL                  success;
   DWORD                 creationFlags;
   NSString              *cmdLineString;
   wchar_t               *cmdLine;
   wchar_t               *envBlock;
   wchar_t               *wideDir;
   NSUInteger            dirLen;
   unichar               *utf32;
   HANDLE                hStdIn, hStdOut, hStdErr;

   if( _status != _NSTaskIsIdle)
      MulleObjCThrowInvalidArgumentException( @"Task already launched");

   if( ! _launchPath)
      MulleObjCThrowInvalidArgumentException( @"No launch path set");

   // Build command line as wchar_t
   cmdLineString = _buildCommandLineString( _launchPath, _arguments);
   if( ! cmdLineString)
      MulleObjCThrowInternalInconsistencyException( @"Failed to build command line");

   cmdLine = _createWideCString( cmdLineString);

   // Build environment block (NULL inherits parent environment)
   envBlock = _environment ? _buildEnvironmentBlock( _environment) : NULL;

   // Build working directory wchar_t (NULL inherits parent cwd)
   wideDir = NULL;
   if( _directoryPath)
   {
      dirLen  = [_directoryPath length];
      wideDir = mulle_malloc( (dirLen + 1) * sizeof( wchar_t));
      utf32   = mulle_malloc( dirLen * sizeof( unichar));

      [_directoryPath getCharacters:utf32 range:NSMakeRange( 0, dirLen)];

      {
         NSUInteger   j;

         for( j = 0; j < dirLen; j++)
         {
            unichar c = utf32[ j];
            wideDir[ j] = (c == '/') ? '\\' : (wchar_t) c;
         }
      }
      wideDir[ dirLen] = 0;
      mulle_free( utf32);
   }

   // Get pipe handles if set
   hStdIn  = _standardInput  ? (HANDLE) [_standardInput _fileDescriptorForReading]  : GetStdHandle( STD_INPUT_HANDLE);
   hStdOut = _standardOutput ? (HANDLE) [_standardOutput _fileDescriptorForWriting] : GetStdHandle( STD_OUTPUT_HANDLE);
   hStdErr = _standardError  ? (HANDLE) [_standardError _fileDescriptorForWriting]  : GetStdHandle( STD_ERROR_HANDLE);

   // Make parent's pipe ends non-inheritable to prevent child from inheriting them.
   // This is critical for EOF detection: if child inherits parent's read end of stdout,
   // the pipe never signals EOF even after parent closes write end.
   if( [_standardInput isKindOfClass:[NSPipe class]])
      SetHandleInformation( (HANDLE) [_standardInput _fileDescriptorForWriting], HANDLE_FLAG_INHERIT, 0);
   if( [_standardOutput isKindOfClass:[NSPipe class]])
      SetHandleInformation( (HANDLE) [_standardOutput _fileDescriptorForReading], HANDLE_FLAG_INHERIT, 0);
   if( [_standardError isKindOfClass:[NSPipe class]])
      SetHandleInformation( (HANDLE) [_standardError _fileDescriptorForReading], HANDLE_FLAG_INHERIT, 0);

   // Setup startup info
   ZeroMemory( &si, sizeof( si));
   si.cb         = sizeof( si);
   si.dwFlags    = STARTF_USESTDHANDLES;
   si.hStdInput  = hStdIn;
   si.hStdOutput = hStdOut;
   si.hStdError  = hStdErr;

   ZeroMemory( &pi, sizeof( pi));

   creationFlags = envBlock ? CREATE_UNICODE_ENVIRONMENT : 0;

   success = CreateProcessW(
      NULL,           // Application name (use command line)
      cmdLine,        // Command line
      NULL,           // Process security
      NULL,           // Thread security
      TRUE,           // Inherit handles (for pipes)
      creationFlags,  // Creation flags
      envBlock,       // Environment block (NULL = inherit)
      wideDir,        // Current directory (NULL = inherit)
      &si,            // Startup info
      &pi             // Process info
   );

   mulle_free( cmdLine);
   mulle_free( envBlock);
   mulle_free( wideDir);

   if( ! success)
   {
      _status = _NSTaskHasFailedLaunching;
      MulleObjCThrowInternalInconsistencyException( @"CreateProcess failed: %lu",
                                                     GetLastError());
   }

   // Store process info
   _pid        = (int) pi.dwProcessId;
   _taskHandle = pi.hProcess;
   _status     = _NSTaskIsPresumablyRunning;

   // Close thread handle (not needed)
   CloseHandle( pi.hThread);

   //
   // Close child-side pipe handles in parent process.
   // This is essential for proper EOF detection: if the parent holds
   // the child's write end of stdout/stderr, readDataToEndOfFile will
   // block forever because the pipe never signals EOF.
   //
   if( [_standardInput isKindOfClass:[NSPipe class]])
      [[_standardInput fileHandleForReading] closeFile];
   if( [_standardOutput isKindOfClass:[NSPipe class]])
      [[_standardOutput fileHandleForWriting] closeFile];
   if( [_standardError isKindOfClass:[NSPipe class]])
      [[_standardError fileHandleForWriting] closeFile];
}


- (void) waitUntilExit
{
   HANDLE   hProcess;
   DWORD    exitCode;

   if( _status != _NSTaskIsPresumablyRunning)
      return;

   hProcess = (HANDLE) _taskHandle;

   WaitForSingleObject( hProcess, INFINITE);

   GetExitCodeProcess( hProcess, &exitCode);
   _terminationStatus = (int) exitCode;
   _status = _NSTaskHasTerminated;

   CloseHandle( hProcess);
   _taskHandle = NULL;
}


- (BOOL) isRunning
{
   HANDLE   hProcess;
   DWORD    exitCode;

   if( _status != _NSTaskIsPresumablyRunning)
      return( NO);

   hProcess = (HANDLE) _taskHandle;

   if( GetExitCodeProcess( hProcess, &exitCode))
   {
      if( exitCode != STILL_ACTIVE)
      {
         _terminationStatus = (int) exitCode;
         _status = _NSTaskHasTerminated;
         CloseHandle( hProcess);
         _taskHandle = NULL;
         return( NO);
      }
   }

   return( YES);
}


- (void) terminate
{
   HANDLE   hProcess;

   if( _status != _NSTaskIsPresumablyRunning)
      return;

   hProcess = (HANDLE) _taskHandle;

   TerminateProcess( hProcess, 1);
   [self waitUntilExit];
}


- (void) interrupt
{
   [self terminate];
}


- (BOOL) suspend
{
   return( NO);
}


- (BOOL) resume
{
   return( NO);
}

@end

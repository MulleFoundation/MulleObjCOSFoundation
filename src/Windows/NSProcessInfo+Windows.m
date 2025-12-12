/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSProcessInfo+Windows.m is a part of MulleObjCOSFoundation
 *
 *  Copyright (C) 2024 Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Windows implementation of NSProcessInfo
 *
 *  Functionally identical to Linux implementation using Windows APIs
 *
 */

#define _GNU_SOURCE

#import "import-private.h"
#import "NSProcessInfo+Windows.h"

// other files in this library

// other libraries of MulleObjCOSFoundation
#import <MulleObjCOSBaseFoundation/NSArray+OSBase-Private.h>
#import <MulleObjCOSBaseFoundation/NSDictionary+OSBase-Private.h>

// Windows headers
#include <windows.h>
#include <process.h>
#include <stdio.h>
#include <objbase.h>

// mulle-core headers for improved functionality
#import <mulle-core/mulle-core.h>


// Helper function for robust Windows error handling with mulle-core
static NSString *mulle_windows_error_string(DWORD errorCode, struct mulle_allocator *allocator)
{
   LPWSTR   messageW = NULL;
   char     *messageA = NULL;
   NSString *result = nil;
   size_t   size;

   // Get Windows error message
   size = FormatMessageW(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM |
                         FORMAT_MESSAGE_IGNORE_INSERTS,
                         NULL, errorCode, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                         (LPWSTR)&messageW, 0, NULL);

   if (size > 0 && messageW)
   {
      // Try mulle-utf conversion first
      messageA = mulle_utf16_to_utf8_string( messageW, size, allocator);
      if (messageA)
      {
         result = [[NSString alloc] initWithCString:messageA length:strlen(messageA)];
         mulle_free( messageA);
      }
      else
      {
         // Fallback conversion
         int lenA = WideCharToMultiByte(CP_UTF8, 0, messageW, size, NULL, 0, NULL, NULL);
         if (lenA > 0)
         {
            messageA = mulle_allocator_malloc( allocator, lenA + 1);
            WideCharToMultiByte(CP_UTF8, 0, messageW, size, messageA, lenA, NULL, NULL);
            messageA[lenA] = '\0';

            result = [[NSString alloc] initWithCString:messageA length:lenA];
            mulle_allocator_free( allocator, messageA);
         }
      }
      LocalFree(messageW);
   }

   return result ?: @"Unknown Windows error";
}


@implementation NSProcessInfo( Windows)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCLoader), @selector( MulleObjCOSWindowsFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}


#pragma mark - Arguments

// Helper function to convert Windows UTF-16 command line to UTF-8 argc/argv using mulle-core
static char **convertCommandLineToArgv(int *argc)
{
   LPWSTR        *argvW;
   int           argcW;
   char          **argv;
   int           i;
   struct mulle_allocator   *allocator;

   allocator = mulle_objc_universe_get_allocator( __MULLE_OBJC_UNIVERSENAME__);

   argvW = CommandLineToArgvW(GetCommandLineW(), &argcW);
   if (!argvW)
      return NULL;

   argv = mulle_allocator_calloc( allocator, argcW + 1, sizeof(char *));
   if (!argv)
   {
      LocalFree(argvW);
      return NULL;
   }

   for (i = 0; i < argcW; i++)
   {
      int      lenW;
      int      lenA;
      char     *utf8_string;

      lenW = lstrlenW(argvW[i]);

      // Use mulle-utf for better UTF-16 to UTF-8 conversion
      utf8_string = mulle_utf16_to_utf8_string( argvW[i], lenW, allocator);
      if (utf8_string)
      {
         argv[i] = utf8_string;
      }
      else
      {
         // Fallback to original method if mulle-utf fails
         lenA = WideCharToMultiByte(CP_UTF8, 0, argvW[i], lenW, NULL, 0, NULL, NULL);
         if (lenA > 0)
         {
            argv[i] = mulle_allocator_malloc( allocator, lenA + 1);
            WideCharToMultiByte(CP_UTF8, 0, argvW[i], lenW, argv[i], lenA, NULL, NULL);
            argv[i][lenA] = '\0';
         }
      }
   }

   LocalFree(argvW);
   *argc = argcW;
   return argv;
}


static void   unlazyArguments( NSProcessInfo *self)
{
   int                      argc;
   char                     **argv;
   struct mulle_allocator   *allocator;

   allocator = mulle_objc_universe_get_allocator( __MULLE_OBJC_UNIVERSENAME__);

   argv = convertCommandLineToArgv(&argc);
   if (!argv)
      MulleObjCThrowInternalInconsistencyException(@"can't get argc/argv from Windows command line");

   self->_arguments = [NSArray _newWithArgc:argc argv:argv];

   // Free the converted argv using proper allocator
   for (int i = 0; i < argc; i++)
   {
      if (argv[i])
         mulle_allocator_free( allocator, argv[i]);
   }
   mulle_allocator_free( allocator, argv);
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
   LPWSTR                   envStringsW;
   LPWSTR                   envW;
   NSMutableDictionary      *dict;
   struct mulle_allocator   *allocator;
   struct mulle_buffer      keyBuffer;
   struct mulle_buffer      valBuffer;

   allocator = mulle_objc_universe_get_allocator( __MULLE_OBJC_UNIVERSENAME__);

   envStringsW = GetEnvironmentStringsW();
   if (!envStringsW)
   {
      self->_environment = @{};
      return;
   }

   dict = [NSMutableDictionary dictionary];

   // Use mulle_buffer for efficient string building
   mulle_buffer_init( &keyBuffer, allocator);
   mulle_buffer_init( &valBuffer, allocator);

   for (envW = envStringsW; *envW; envW += lstrlenW(envW) + 1)
   {
      LPWSTR equals = wcschr(envW, L'=');
      if (equals && equals != envW)
      {
         int   keyLenW = (int)(equals - envW);
         int   valLenW = lstrlenW(equals + 1);
         char  *keyA;
         char  *valA;

         // Reset buffers
         mulle_buffer_reset( &keyBuffer);
         mulle_buffer_reset( &valBuffer);

         // Try mulle-utf conversion first, fallback to Windows API
         keyA = mulle_utf16_to_utf8_string( envW, keyLenW, allocator);
         valA = mulle_utf16_to_utf8_string( equals + 1, valLenW, allocator);

         if (keyA && valA)
         {
            NSString *key = [[NSString alloc] initWithCString:keyA length:strlen(keyA)];
            NSString *val = [[NSString alloc] initWithCString:valA length:strlen(valA)];
            dict[key] = val;
            mulle_free( keyA);
            mulle_free( valA);
         }
         else
         {
            // Fallback to Windows API conversion
            int keyLenA = WideCharToMultiByte(CP_UTF8, 0, envW, keyLenW, NULL, 0, NULL, NULL);
            int valLenA = WideCharToMultiByte(CP_UTF8, 0, equals + 1, valLenW, NULL, 0, NULL, NULL);

            if (keyLenA > 0 && valLenA > 0)
            {
               mulle_buffer_guarantee( &keyBuffer, keyLenA + 1);
               mulle_buffer_guarantee( &valBuffer, valLenA + 1);

               WideCharToMultiByte(CP_UTF8, 0, envW, keyLenW,
                                   mulle_buffer_get_bytes( &keyBuffer), keyLenA, NULL, NULL);
               WideCharToMultiByte(CP_UTF8, 0, equals + 1, valLenW,
                                   mulle_buffer_get_bytes( &valBuffer), valLenA, NULL, NULL);

               mulle_buffer_set_length( &keyBuffer, keyLenA);
               mulle_buffer_set_length( &valBuffer, valLenA);

               NSString *key = [[NSString alloc] initWithBytes:mulle_buffer_get_bytes( &keyBuffer)
                                                          length:keyLenA
                                                        encoding:NSUTF8StringEncoding];
               NSString *val = [[NSString alloc] initWithBytes:mulle_buffer_get_bytes( &valBuffer)
                                                          length:valLenA
                                                        encoding:NSUTF8StringEncoding];
               dict[key] = val;
            }
         }
      }
   }

   FreeEnvironmentStringsW(envStringsW);
   mulle_buffer_done( &keyBuffer);
   mulle_buffer_done( &valBuffer);

   self->_environment = dict;
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
   WCHAR                    bufW[MAX_PATH + 1];
   DWORD                    lenW;
   char                     *bufA;
   struct mulle_allocator   *allocator;
   DWORD                    errorCode;

   allocator = mulle_objc_universe_get_allocator( __MULLE_OBJC_UNIVERSENAME__);

   lenW = GetModuleFileNameW(NULL, bufW, MAX_PATH);
   if (lenW == 0)
   {
      errorCode = GetLastError();
      NSString *errorMsg = mulle_windows_error_string(errorCode, allocator);
      MulleObjCThrowInternalInconsistencyException(@"can't get executable path from GetModuleFileNameW: %@ (error %lu)", errorMsg, errorCode);
   }

   // Try mulle-utf conversion first
   bufA = mulle_utf16_to_utf8_string( bufW, lenW, allocator);
   if (bufA)
   {
      self->_executablePath = [[NSString alloc] initWithCString:bufA length:strlen(bufA)];
      mulle_free( bufA);
   }
   else
   {
      // Fallback to Windows API conversion
      int lenA = WideCharToMultiByte(CP_UTF8, 0, bufW, lenW, NULL, 0, NULL, NULL);
      if (lenA == 0)
      {
         errorCode = GetLastError();
         NSString *errorMsg = mulle_windows_error_string(errorCode, allocator);
         MulleObjCThrowInternalInconsistencyException(@"can't convert executable path to UTF-8: %@ (error %lu)", errorMsg, errorCode);
      }

      bufA = mulle_allocator_malloc( allocator, lenA + 1);
      WideCharToMultiByte(CP_UTF8, 0, bufW, lenW, bufA, lenA, NULL, NULL);
      bufA[lenA] = '\0';

      self->_executablePath = [[NSString alloc] initWithCString:bufA length:lenA];
      mulle_allocator_free( allocator, bufA);
   }
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
   return( @"Windows");
}


- (NSUInteger) operatingSystem
{
   return( NSWindowsNTOperatingSystem);
}


#pragma mark - processName

- (NSString *) processName
{
   NSString   *s;

   s = [self _executablePath];
   s = [s lastPathComponent];
   return( s);
}


- (void) setProcessName:(NSString *) name
{
   // Not implemented on Windows - same as Linux
   // Windows has SetConsoleTitle() but that's different from process name
}


#pragma mark - Process Identifier

- (int) processIdentifier
{
   return( (int) GetCurrentProcessId());
}

// we don't do this anymore (use MulleObjCUUID)
#if 0
#pragma mark - Globally Unique String

- (NSString *) globallyUniqueString
{
   GUID                     guid;
   WCHAR                    guidW[39];  // {XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}
   char                     *guidA;
   NSString                 *result;
   struct mulle_allocator   *allocator;
   struct mulle_buffer      guidBuffer;

   allocator = mulle_objc_universe_get_allocator( __MULLE_OBJC_UNIVERSENAME__);

   if (S_OK != CoCreateGuid(&guid))
      MulleObjCThrowInternalInconsistencyException(@"can't create GUID");

   // Format as string: {XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}
   swprintf(guidW, 39, L"{%08X-%04X-%04X-%02X%02X-%02X%02X%02X%02X%02X%02X}",
            guid.Data1, guid.Data2, guid.Data3,
            guid.Data4[0], guid.Data4[1], guid.Data4[2], guid.Data4[3],
            guid.Data4[4], guid.Data4[5], guid.Data4[6], guid.Data4[7]);

   // Try mulle-utf conversion first
   guidA = mulle_utf16_to_utf8_string( guidW, -1, allocator);
   if (guidA)
   {
      result = [[NSString alloc] initWithCString:guidA length:strlen(guidA)];
      mulle_free( guidA);
   }
   else
   {
      // Fallback to Windows API conversion using mulle_buffer
      mulle_buffer_init( &guidBuffer, allocator);

      int lenA = WideCharToMultiByte(CP_UTF8, 0, guidW, -1, NULL, 0, NULL, NULL);
      if (lenA > 0)
      {
         mulle_buffer_guarantee( &guidBuffer, lenA);
         WideCharToMultiByte(CP_UTF8, 0, guidW, -1,
                             mulle_buffer_get_bytes( &guidBuffer), lenA, NULL, NULL);
         mulle_buffer_set_length( &guidBuffer, lenA - 1);  // Exclude null terminator

         result = [[NSString alloc] initWithBytes:mulle_buffer_get_bytes( &guidBuffer)
                                           length:mulle_buffer_get_length( &guidBuffer)
                                         encoding:NSUTF8StringEncoding];
      }
      else
      {
         result = nil;
      }

      mulle_buffer_done( &guidBuffer);
   }

   return( result);
}
#endif


@end
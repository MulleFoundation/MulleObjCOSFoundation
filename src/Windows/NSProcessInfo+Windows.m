/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSProcessInfo+Windows.m is a part of MulleObjCOSFoundation
 *
 *  Copyright (C) 2024 Mulle kybernetiK.
 *  All rights reserved.
 *
 */

#import "import-private.h"

// other files in this library
#import "NSErrorWindows.h"
#import "NSFileManager+Windows.h"
#import "NSString+Windows.h"

// Windows headers
#include <windows.h>
#include <shellapi.h>


@implementation NSProcessInfo( Windows)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCDeps), @selector( MulleObjCOSWindowsFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}


- (NSInteger) processIdentifier
{
   MulleObjCSetWindowsErrorDomain();

   return( (int) GetCurrentProcessId());
}


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


- (NSArray *) arguments
{
   LPWSTR   *argv;
   int      argc;
   int      i;
   id       *objects;

   if( _arguments)
      return( _arguments);

   argv = CommandLineToArgvW( GetCommandLineW(), &argc);
   if( ! argv)
   {
      MulleObjCThrowInternalInconsistencyException( @"CommandLineToArgvW failed: %lu",
                                                     GetLastError());
      return( nil);
   }

   objects = mulle_allocator_malloc( MulleObjCInstanceGetAllocator( self),
                                     argc * sizeof( id));
   for( i = 0; i < argc; i++)
   {
      objects[ i] = [[NSFileManager defaultManager]
                        stringWithFileSystemRepresentationUTF16:(mulle_utf16_t *) argv[ i]
                                                         length:wcslen( argv[ i])];
   }

   _arguments = [[NSArray alloc] initWithObjects:objects
                                           count:argc];

   mulle_allocator_free( MulleObjCInstanceGetAllocator( self), objects);
   LocalFree( argv);

   return( _arguments);
}


- (NSDictionary *) environment
{
   LPWCH                env;
   LPWCH                p;
   NSMutableDictionary  *dict;

   if( _environment)
      return( _environment);

   env = GetEnvironmentStringsW();
   if( ! env)
   {
      MulleObjCThrowInternalInconsistencyException( @"GetEnvironmentStringsW failed: %lu",
                                                     GetLastError());
      return( nil);
   }

   dict = [NSMutableDictionary new];

   for( p = env; *p; )
   {
      NSString   *line;
      NSString   *key;
      NSString   *value;
      NSRange    range;
      size_t     len;

      len  = wcslen( p);
      line = [[NSString alloc] mulleInitWithUTF16Characters:(mulle_utf16_t *) p
                                                     length:len];
      p   += len + 1;

      range = [line rangeOfString:@"="];
      if( range.length == 0)
      {
         [line release];
         continue;
      }

      key   = [[line substringToIndex:range.location] retain];
      value = [[line substringFromIndex:range.location + 1] retain];
      [line release];

      [dict mulleSetRetainedObject:value
                      forCopiedKey:key];
   }

   FreeEnvironmentStringsW( env);

   _environment = [dict copy];
   [dict release];

   return( _environment);
}


#pragma mark - Executable Path

static void   unlazyExecutablePath( NSProcessInfo *self)
{
   wchar_t    buf[ MAX_PATH + 1];
   DWORD      len;
   size_t     charlen;
   NSString   *path;

   len = GetModuleFileNameW( NULL, buf, MAX_PATH);
   if( ! len || len == MAX_PATH)
      MulleObjCThrowInternalInconsistencyException( @"can't get executable path from GetModuleFileNameW (%lu)", GetLastError());

   charlen = wcslen( buf);
   path    = [[NSString alloc] mulleInitWithUTF16Characters:(mulle_utf16_t *) buf
                                                      length:charlen];
   // Convert to Unix format for NSString path methods
   self->_executablePath = [[path mulleUnixFileSystemString] retain];
   [path release];
}


- (NSString *) _executablePath
{
   if( ! (id) _executablePath)
      unlazyExecutablePath( self);
   return( _executablePath);
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
   MULLE_C_UNUSED( name);
   // Windows doesn't support changing the process name at runtime
   // This is a no-op, like on Linux
}

@end
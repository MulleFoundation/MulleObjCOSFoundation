//
//  NSBundle+Windows.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 24.01.26
//  Copyright © 2026 Mulle kybernetiK. All rights reserved.
//
#import "import-private.h"

#import <MulleObjCOSBaseFoundation/NSBundle-Private.h>

#import "NSFileManager+Windows.h"
#import "NSString+Windows.h"

// std-c and dependencies
#include <windows.h>
#include <psapi.h>


@implementation NSBundle( Windows)

+ (BOOL) isBundleFilesystemExtension:(NSString *) extension
{
   return( [extension isEqualToString:@"dll"]);
}


+ (NSString *) _mainBundlePathForExecutablePath:(NSString *) executablePath
{
   NSString   *dir;
   NSString   *unixPath;
   
   mulle_fprintf( stderr, "DEBUG _mainBundlePathForExecutablePath: input='%s'\n", 
                  executablePath ? [executablePath UTF8String] : "(nil)");
   
   if( ! executablePath || ! [executablePath length])
   {
      NSFileManager   *manager;
      manager = [NSFileManager defaultManager];
      return( [manager currentDirectoryPath]);
   }

   // Convert to Unix format first
   unixPath = [executablePath mulleUnixFileSystemString];
   
   // On Windows, the bundle path is the directory containing the executable
   dir = [unixPath stringByDeletingLastPathComponent];
   
   mulle_fprintf( stderr, "DEBUG _mainBundlePathForExecutablePath: returning dir='%s'\n",
                  dir ? [dir UTF8String] : "(nil)");
   
   return( dir);
}


- (NSString *) _windowsResourcePath
{
   NSString   *s;
   NSString   *name;

   s    = [self executablePath];
   name = [[s lastPathComponent] stringByDeletingPathExtension];
   
   s = [s stringByDeletingLastPathComponent]; // remove executable
   s = [s stringByAppendingPathComponent:@"Resources"];
   s = [s stringByAppendingPathComponent:name];

   return( s);
}


- (NSString *) _resourcePath
{
   return( [self _windowsResourcePath]);
}


- (NSString *) builtInPlugInsPath
{
   return( [[self resourcePath] stringByAppendingPathComponent:@"PlugIns"]);
}


- (NSString *) _executablePath
{
   NSFileManager   *fileManager;

   mulle_fprintf( stderr, "DEBUG _executablePath: _path='%s', _executablePath.object='%s'\n", 
                  _path ? [_path UTF8String] : "(nil)",
                  _executablePath.object ? [_executablePath.object UTF8String] : "(nil)");

   // If we have an explicit executable path set, return it
   if( _executablePath.object)
      return( _executablePath.object);

   // Otherwise check if _path itself is executable
   if( ! _path)
      return( nil);

   fileManager = [NSFileManager defaultManager];
   if( [fileManager isExecutableFileAtPath:_path])
   {
      mulle_fprintf( stderr, "DEBUG _executablePath: _path is executable, returning it\n");
      return( _path);
   }
   
   mulle_fprintf( stderr, "DEBUG _executablePath: NOT executable, returning nil\n");
   return( nil);
}


+ (NSBundle *) bundleForClass:(Class) aClass
{
   NSDictionary                     *bundleInfo;
   NSBundle                         *bundle;
   void                             *classAddress;
   struct _MulleObjCSharedLibrary   libInfo;
   NSString                         *path;
   NSString                         *bundlePath;
   NSString                         *exePath;
   HMODULE                          hModule;
   wchar_t                          modulePath[ MAX_PATH];

   if( ! aClass)
      return( nil);

   classAddress = MulleObjCClassGetLoadAddress( aClass);
   if( ! classAddress)
      return( [NSBundle mainBundle]);

   // Get module handle for address
   if( GetModuleHandleExW( GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS |
                           GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                           (LPCWSTR) classAddress,
                           &hModule))
   {
      DWORD   len;

      len = GetModuleFileNameW( hModule, modulePath, MAX_PATH);
      if( len && len < MAX_PATH)
      {
         path = [[[NSString alloc] mulleInitWithUTF16Characters:(mulle_utf16_t *) modulePath
                                                          length:len] autorelease];
         
         bundleInfo = [self mulleRegisteredBundleInfo];
         for( bundlePath in bundleInfo)
         {
            bundle  = [bundleInfo objectForKey:bundlePath];
            exePath = [bundle executablePath];
            if( [exePath isEqualToString:path])
               return( bundle);
         }
      }
   }

   // Create pseudo bundle
   libInfo.path   = nil;
   libInfo.start  = classAddress;
   libInfo.end    = classAddress;
   libInfo.handle = NULL;

   path   = [NSString stringWithFormat:@"/pseudoproc/memory/%llx", classAddress];
   bundle = [[[self alloc] _mulleInitWithPath:path
                            sharedLibraryInfo:&libInfo] autorelease];
   return( bundle);
}


- (BOOL) loadBundle
{
   NSString   *exePath;
   NSUInteger len;
   HMODULE    hModule;
   BOOL       rval;

   if( _handle)
      return( YES);

   exePath = [self executablePath];
   if( ! exePath)
      return( NO);

   len  = [exePath length];
   rval = YES;
   mulle_alloca_do( utf32, unichar, len)
   {
      mulle_alloca_do( widePath, wchar_t, len + 1)
      {
         [exePath getCharacters:utf32 range:NSMakeRange( 0, len)];
         _mulle_utf32_convert_to_utf16( (mulle_utf32_t *) utf32, len, (mulle_utf16_t *) widePath);
         widePath[ len] = 0;

         [self willLoad];

         hModule = LoadLibraryW( widePath);

         if( ! hModule)
         {
            rval = NO;
            break;
         }

         _handle = hModule;

         [self didLoad];
      }
   }

   return( rval);
}


- (BOOL) unloadBundle
{
   if( ! _handle)
      return( YES);

   if( ! FreeLibrary( (HMODULE) _handle))
      return( NO);

   _handle = NULL;

   return( YES);
}


- (void *) _addressOfSymbol:(NSString *) symbolName
{
   char   *c_name;
   void   *address;

   if( ! _handle)
      return( NULL);

   c_name = (char *) [symbolName UTF8String];
   if( ! c_name)
      return( NULL);

   address = GetProcAddress( (HMODULE) _handle, c_name);
   return( address);
}


+ (NSData *) _allSharedLibraries
{
   NSMutableData   *data;
   HANDLE          hProcess;
   HMODULE         hMods[1024];
   DWORD           cbNeeded;
   unsigned int    i;

   data     = [NSMutableData data];
   hProcess = GetCurrentProcess();

   if( EnumProcessModules( hProcess, hMods, sizeof( hMods), &cbNeeded))
   {
      for( i = 0; i < (cbNeeded / sizeof( HMODULE)); i++)
      {
         wchar_t                          szModName[ MAX_PATH];
         struct _MulleObjCSharedLibrary   libInfo;
         NSFileManager                    *manager;
         DWORD                            len;

         len = GetModuleFileNameW( hMods[ i], szModName, sizeof( szModName) / sizeof( wchar_t));
         if( len && len < MAX_PATH)
         {
            manager       = [NSFileManager defaultManager];
            libInfo.path  = [manager stringWithFileSystemRepresentationUTF16:szModName
                                                                      length:len];
            libInfo.start  = NULL;
            libInfo.end    = NULL;
            libInfo.handle = hMods[ i];

            [data appendBytes:&libInfo
                       length:sizeof( libInfo)];
         }
      }
   }

   return( data);
}

@end

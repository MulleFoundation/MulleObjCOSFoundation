//
//  NSPathUtilities+Windows.m
//  MulleObjCOSFoundation
//
//  Created by Nat! on 24.01.26
//  Copyright © 2026 Mulle kybernetiK. All rights reserved.
//
#import "import-private.h"

#import <MulleObjCOSBaseFoundation/NSPathUtilities+OSBase-Private.h>

// std-c and dependencies
#include <windows.h>
// windows.h temporarily defines 'interface' as 'struct' for COM headers, but
// restores it via push/pop_macro on exit, leaving 'interface' undefined.
// shlobj.h uses 'interface' via DECLARE_INTERFACE (combaseapi.h), so we must
// redefine it as 'struct' for the duration of this include.
#pragma push_macro("interface")
#define interface struct
#include <shlobj.h>
#pragma pop_macro("interface")


// Helper to convert Windows path (UTF-16 with \) to Foundation path (UTF-32 with /)
// Convention: C:\path -> /c/path (lowercase drive letter, no colon)
static NSString *_stringFromWindowsPath( wchar_t *widePath)
{
   NSMutableString   *str;
   NSString          *result;
   NSUInteger        len;
   unichar           drive;
   
   if( ! widePath || ! *widePath)
      return( nil);
   
   len = wcslen( widePath);
   str = [[[NSMutableString alloc] mulleInitWithUTF16Characters:(mulle_utf16_t *) widePath
                                                         length:len] autorelease];
   
   result = [str stringByReplacingOccurrencesOfString:@"\\"
                                           withString:@"/"];
   
   // Convert drive letter: C: -> /c (lowercase, no colon)
   if( [result length] >= 2 && [result characterAtIndex:1] == ':')
   {
      drive = [result characterAtIndex:0];
      if( (drive >= 'A' && drive <= 'Z') || (drive >= 'a' && drive <= 'z'))
      {
         // Lowercase the drive letter and remove colon
         drive = (drive >= 'A' && drive <= 'Z') ? (drive + 32) : drive;
         result = [NSString stringWithFormat:@"/%c%@", 
                   (char) drive,
                   [result substringFromIndex:2]];
      }
   }
   
   return( result);
}


static NSString *WindowsHomeDirectory( void)
{
   wchar_t   path[ MAX_PATH];
   
   if( SUCCEEDED( SHGetFolderPathW( NULL, CSIDL_PROFILE, NULL, 0, path)))
      return( _stringFromWindowsPath( path));
   
   // Fallback to USERPROFILE env var
   char  *s = getenv( "USERPROFILE");
   if( s)
      return( [NSString stringWithCString:s]);
   
   return( @"/c/");
}


static NSString *WindowsHomeDirectoryForUser( NSString *userName)
{
   // Windows doesn't have easy user home lookup
   // Just return generic Users path
   return( [NSString stringWithFormat:@"C:/Users/%@", userName]);
}


static NSString *WindowsRootDirectory( void)
{
   wchar_t   path[ MAX_PATH];
   
   GetWindowsDirectoryW( path, MAX_PATH);
   path[ 3] = 0;  // Truncate to "C:\"
   
   return( _stringFromWindowsPath( path));
}


static NSString *WindowsTemporaryDirectory( void)
{
   wchar_t   path[ MAX_PATH];
   
   if( GetTempPathW( MAX_PATH, path))
      return( _stringFromWindowsPath( path));
   
   return( @"C:/Temp");
}


static NSString *WindowsUserName( void)
{
   wchar_t   name[ 256];
   DWORD     size = 256;
   
   if( GetUserNameW( name, &size))
      return( _stringFromWindowsPath( name));
   
   // Fallback to USERNAME env var
   char  *s = getenv( "USERNAME");
   if( s)
      return( [NSString stringWithCString:s]);
   
   return( @"User");
}


static NSString *WindowsFullUserName( void)
{
   // Windows doesn't have easy full name lookup
   return( WindowsUserName());
}


static NSString *pathForType( NSSearchPathDirectory type, NSSearchPathDomainMask domain)
{
   wchar_t   path[ MAX_PATH];
   int       csidl;
   
   // Map to Windows CSIDL constants
   switch( type)
   {
   case NSApplicationDirectory:
      csidl = (domain == NSUserDomainMask) ? CSIDL_PROGRAMS : CSIDL_PROGRAM_FILES;
      break;
      
   case NSApplicationSupportDirectory:
      csidl = (domain == NSUserDomainMask) ? CSIDL_APPDATA : CSIDL_COMMON_APPDATA;
      break;
      
   case NSCachesDirectory:
      csidl = CSIDL_LOCAL_APPDATA;
      break;
      
   case NSDesktopDirectory:
      csidl = (domain == NSUserDomainMask) ? CSIDL_DESKTOP : CSIDL_COMMON_DESKTOPDIRECTORY;
      break;
      
   case NSDocumentDirectory:
      csidl = (domain == NSUserDomainMask) ? CSIDL_PERSONAL : CSIDL_COMMON_DOCUMENTS;
      break;
      
   case NSLibraryDirectory:
      csidl = (domain == NSUserDomainMask) ? CSIDL_APPDATA : CSIDL_COMMON_APPDATA;
      break;
      
   case NSMusicDirectory:
      csidl = CSIDL_MYMUSIC;
      break;
      
   case NSPicturesDirectory:
      csidl = CSIDL_MYPICTURES;
      break;
      
   case NSMoviesDirectory:
      csidl = CSIDL_MYVIDEO;
      break;
      
   case NSUserDirectory:
      csidl = CSIDL_PROFILE;
      break;
      
   default:
      return( nil);
   }
   
   if( SUCCEEDED( SHGetFolderPathW( NULL, csidl, NULL, 0, path)))
      return( _stringFromWindowsPath( path));
   
   return( nil);
}


static NSArray *WindowsSearchPathForDirectoriesInDomains( NSSearchPathDirectory type,
                                                          NSSearchPathDomainMask domains)
{
   NSMutableArray          *array;
   NSSearchPathDomainMask  currentDomain;
   NSSearchPathDomainMask  leftoverDomains;
   NSString                *path;
   
   array           = [NSMutableArray array];
   leftoverDomains = domains & (NSUserDomainMask | NSLocalDomainMask | NSSystemDomainMask);
   
   while( leftoverDomains)
   {
      if( leftoverDomains & NSUserDomainMask)
         currentDomain = NSUserDomainMask;
      else if( leftoverDomains & NSLocalDomainMask)
         currentDomain = NSLocalDomainMask;
      else
         currentDomain = NSSystemDomainMask;
      
      leftoverDomains &= ~currentDomain;
      
      path = pathForType( type, currentDomain);
      if( path)
         [array addObject:path];
   }
   
   return( array);
}


static _NSPathUtilityVectorTable _WindowsTable =
{
   WindowsFullUserName,
   WindowsHomeDirectory,
   WindowsHomeDirectoryForUser,
   WindowsSearchPathForDirectoriesInDomains,
   WindowsRootDirectory,
   WindowsTemporaryDirectory,
   WindowsUserName
};


@implementation _NSPathUtilityVectorTable_Loader( Windows)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCDeps), @selector( MulleObjCOSBaseFoundation) },
      { 0, 0 }
   };
   
   return( dependencies);
}


+ (void) load
{
   _NSPathUtilityVectors = &_WindowsTable;
}

@end

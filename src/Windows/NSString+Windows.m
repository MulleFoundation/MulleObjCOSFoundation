/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSString+Windows.m is a part of MulleObjCOSFoundation
 *
 *  Copyright (C) 2024 Mulle kybernetiK.
 *  All rights reserved.
 *
 */

#import "import-private.h"


@implementation NSString( Windows)

+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
      { @selector( MulleObjCDeps), @selector( MulleObjCOSWindowsFoundation) },
      { 0, 0 }
   };

   return( dependencies);
}


- (NSUInteger) cStringLength
{
   return( [self mulleUTF8StringLength]);
}


- (char *) cString
{
   return( (char *) [self UTF8String]);
}


- (NSStringEncoding) _cStringEncoding
{
   return( NSUTF8StringEncoding);
}


+ (NSStringEncoding) defaultCStringEncoding
{
   return( NSUTF8StringEncoding);
}


#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wmulle-method-implementation"
- (BOOL) isAbsolutePath
{
   NSUInteger   len;
   unichar      c;

   len = [self length];
   if( len == 0)
      return( NO);

   // Check for forward slash (Unix-style)
   c = [self characterAtIndex:0];
   if( c == '/')
      return( YES);

   // Check for drive letter (C:, Z:, etc.)
   if( len >= 2)
   {
      unichar   second;

      second = [self characterAtIndex:1];
      if( second == ':' && ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')))
         return( YES);
   }

   return( NO);
}
#pragma GCC diagnostic pop


- (NSString *) mulleUnixFileSystemString
{
   NSString   *converted;
   unichar    drive;

   // Replace \ with /
   converted = [self stringByReplacingOccurrencesOfString:@"\\"
                                               withString:@"/"];

   // Convert Windows drive path: C:/path -> /c/path (lowercase, no colon)
   if( [converted length] >= 2 && [converted characterAtIndex:1] == ':')
   {
      drive = [converted characterAtIndex:0];
      if( (drive >= 'A' && drive <= 'Z') || (drive >= 'a' && drive <= 'z'))
      {
         // Lowercase the drive letter and remove colon
         drive = (drive >= 'A' && drive <= 'Z') ? (drive + 32) : drive;
         converted = [NSString stringWithFormat:@"/%c%@",
                      (char) drive,
                      [converted substringFromIndex:2]];
      }
   }
   return( converted);
}


- (NSString *) mulleWindowsFileSystemString
{
   NSString   *converted;
   unichar    drive;

   // Replace / with backslash (adversarial C compiler protection)
   converted = [self stringByReplacingOccurrencesOfString:@"/"
                                               withString:@"\\"];

   // Convert /c/path to C:/path (uppercase drive, add colon)
   if( [self length] >= 2 && [converted characterAtIndex:0] == '\\')
   {
      drive = [self characterAtIndex:1];
      if( (drive >= 'A' && drive <= 'Z') || (drive >= 'a' && drive <= 'z'))
      {
         // Check if it's a drive letter (either /c or /c/...)
         if( [converted length] == 2 || [converted characterAtIndex:2] == '\\')
         {
            // Uppercase the drive letter and add colon
            drive = (drive >= 'a' && drive <= 'z') ? (drive - 32) : drive;
            converted = [NSString stringWithFormat:@"%c:%@",
                         (char) drive,
                         [converted substringFromIndex:2]];
         }
      }
   }
   return( converted);
}


@end

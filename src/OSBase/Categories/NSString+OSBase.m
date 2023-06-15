/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSString+PosixPathHandling.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSString+OSBase.h"

// other files in this library
#import "NSFileManager.h"
#import "NSPathUtilities.h"
#import "NSData+OSBase.h"
#import "NSString+CString.h"

// std-c and dependencies
#import "import-private.h"


#pragma clang diagnostic ignored "-Wparentheses"


@implementation NSString( OSBase)

- (BOOL) isAbsolutePath
{
   return( [self hasPrefix:NSFilePathComponentSeparator]);
}


// use string subclass that keeps components separate
+ (instancetype) pathWithComponents:(NSArray *) components
{
   return( [components componentsJoinedByString:NSFilePathComponentSeparator]);
}

///
// This method can make the following changes in the provided string:
//
// Expand an initial tilde expression using stringByExpandingTildeInPath.
// Reduce empty components and references to the current directory (that
// is, the sequences “//” and “/./”) to single path separators.
// In absolute paths only, resolve references to the parent directory
// (that is, the component “..”) to the real parent directory if possible
// using stringByResolvingSymlinksInPath, which consults the file system
// to resolve each potential symbolic link.
// In relative paths, because symbolic links can’t be resolved, references
// to the parent directory are left in place.
//
// Remove an initial component of “/private” from the path if the result
// still indicates an existing file or directory (checked by consulting
// the file system).
//
- (NSString *) initWithPathComponents:(NSArray *) components
{
   NSString  *s;

   s = [components componentsJoinedByString:NSFilePathComponentSeparator];
   [self autorelease];
   [s retain];

   return( s);
}


- (NSArray *) pathComponents
{
   return( [self componentsSeparatedByString:NSFilePathComponentSeparator]);
}


- (NSString *) mulleStringBySimplifyingPath
{
   return( [self mulleStringBySimplifyingComponentsSeparatedByString:NSFilePathComponentSeparator
                                                        simplifyDots:YES]);
}

//
// this is not what darwin will do (in a category)
//
- (NSString *) _stringByRemovingPrivatePrefix
{
   return( self);
}


- (NSString *) stringByStandardizingPath
{
   NSString        *path;

   path = self;
//   path = [self stringByExpandingTildeInPath];  // already done by symlinks
   path = [path stringByResolvingSymlinksInPath];
   path = [path mulleStringBySimplifyingPath];

   //
   // that's what MacOS does, don't know why.
   // we only do this in Darwin
   path = [path _stringByRemovingPrivatePrefix];

   return( path);
}


// resist the urge, to standardize
//   [@"a" stringByAppendingPathComponent:@"b"]     ->  a/b
//   [@"a/" stringByAppendingPathComponent:@"b"]    ->  a/b
//   [@"/a" stringByAppendingPathComponent:@"b"]    ->  /a/b
//   [@"/a/" stringByAppendingPathComponent:@"b"]   ->  /a/b
//   [@"a" stringByAppendingPathComponent:@"b/"]    ->  a/b
//   [@"a/" stringByAppendingPathComponent:@"b/"]   ->  a/b
//   [@"/a" stringByAppendingPathComponent:@"b/"]   ->  /a/b
//   [@"/a/" stringByAppendingPathComponent:@"b/"]  ->  /a/b
//   [@"a" stringByAppendingPathComponent:@"/b"]    ->  a/b
//   [@"a/" stringByAppendingPathComponent:@"/b"]   ->  a/b
//   [@"/a" stringByAppendingPathComponent:@"/b"]   ->  /a/b
//   [@"/a/" stringByAppendingPathComponent:@"/b"]  ->  /a/b
//   [@"a" stringByAppendingPathComponent:@"/b/"]   ->  a/b
//   [@"a/" stringByAppendingPathComponent:@"/b/"]  ->  a/b
//   [@"/a" stringByAppendingPathComponent:@"/b/"]  ->  /a/b
//   [@"/a/" stringByAppendingPathComponent:@"/b/"] ->  /a/b
//
- (NSString *) stringByAppendingPathComponent:(NSString *) other
{
   return( [self mulleStringByAppendingComponent:other
                               separatedByString:NSFilePathComponentSeparator]);
}


// resist the urge, to standardize
- (NSString *) stringByAppendingPathExtension:(NSString *) extension
{
   NSString   *s;

   s = self;
   if( [s hasSuffix:@"/"])
      s = [self substringToIndex:[self length] - 1];

   return( [s stringByAppendingFormat:@"%@%@", NSFilePathExtensionSeparator, extension]);
}


//
// this only works if ~ is in front
// see: https://developer.apple.com/documentation/foundation/nsstring/1407716-stringbyexpandingtildeinpath?language=objc
//
- (NSString *) stringByExpandingTildeInPath
{
   id        components;
   NSString  *first;
   NSString  *home;

   if( ! [self hasPrefix:@"~"])
      return( self);

   components = [self pathComponents];
   first      = [components objectAtIndex:0];
   if( [first length] == 1)
      home = NSHomeDirectory();
   else
      home = NSHomeDirectoryForUser( [first substringFromIndex:1]);
   if( ! home)
      return( self);

   components = [NSMutableArray arrayWithArray:components];
   [components replaceObjectAtIndex:0
                         withObject:home];
   return( [NSString pathWithComponents:components]);
}


- (NSString *) stringByResolvingSymlinksInPath
{
   NSFileManager     *manager;
   NSArray           *components;
   NSMutableString   *s;
   NSString          *path;
   NSString          *component;
   NSString          *expanded;
   NSString          *best;
   NSUInteger        len;

   path = [self stringByExpandingTildeInPath];
   if( ! [path isAbsolutePath])
      return( path);

   manager    = [NSFileManager defaultManager];
   components = [path componentsSeparatedByString:NSFilePathComponentSeparator];
   s          = [NSMutableString string];
   for( component in components)
   {
      len = [component length];
      if( ! len)
         continue;
      [s appendString:NSFilePathComponentSeparator];
      [s appendString:component];

      best = s;
      while( expanded = [manager pathContentOfSymbolicLinkAtPath:best])
         best = expanded;
      if( best == s)
         continue;
      [s setString:best];
   }
   if( ! [s length])
      return( NSFilePathComponentSeparator);
   return( s);
}


/*
  * /tmp/scratch.tiff -> scratch.tiff
  * /tmp/scratch”     -> scratch
  * /tmp/”            -> tmp
  * scratch           -> scratch
  * /                 -> /
*/
static NSRange  getLastPathComponentRange( NSString *self)
{
   NSRange      range;
   NSUInteger   len;

   len   = [self length];
   range = [self rangeOfString:NSFilePathComponentSeparator
                       options:NSLiteralSearch|NSBackwardsSearch];
   // if found trailing '/', skip it (but only once)
   if( range.location == len - 1)
      range = [self rangeOfString:NSFilePathComponentSeparator
                          options:NSBackwardsSearch
                            range:NSMakeRange( 0, len - 1)];

   if( range.location == 0 || range.length == 0) // is root or just the file
      return( NSMakeRange( 0, len));

   // otherwise range it toge
   range.location++;   // skip over '/'
   return( NSMakeRange( range.location, len - range.location));
}


static NSRange  getPathExtensionRange( NSString *self)
{
   NSRange   range1;
   NSRange   range2;

   // first get lastPathComponent range
   range1 = getLastPathComponentRange( self);
   if( range1.length == 0)
      return( range1);

   range2 = [self rangeOfString:NSFilePathExtensionSeparator
                        options:NSBackwardsSearch
                          range:range1];
   // /.tiff is not an extension!
   if( ! range2.length || range2.location <= range1.location)
      return( NSMakeRange( NSNotFound, 0));

   ++range2.location;
   return( NSMakeRange( range2.location, (range1.location + range1.length) - range2.location));
}


- (NSString *) lastPathComponent
{
   NSRange   range;

   range = getLastPathComponentRange( self);
   if( ! range.length)
      return( self);
   return( [self substringFromIndex:range.location]);
}


- (NSString *) stringByDeletingLastPathComponent
{
   NSRange   range;

   range = getLastPathComponentRange( self);
   if( ! range.length)
      return( self);

   // skip over '/' if available
   if( range.location)
      --range.location;
   return( [self substringToIndex:range.location]);
}


- (NSString *) pathExtension
{
   NSRange   range;

   range = getPathExtensionRange( self);
   if( ! range.length)
      return( @"");
   return( [self substringWithRange:range]);
}


- (NSString *) stringByDeletingPathExtension
{
   NSRange   range;

   range = getPathExtensionRange( self);
   if( ! range.length)
      return( self);

   NSCParameterAssert( range.location);
   // also snip off "dot"
   return( [self substringToIndex:range.location - 1]);
}


//
// TODO: need to convert to proper characterset
//
- (char *) fileSystemRepresentation
{
   return( [[NSFileManager sharedInstance] fileSystemRepresentationWithPath:self]);
}


// this is not as fast as you may think :)
- (BOOL) getFileSystemRepresentation:(char *) buf
                           maxLength:(NSUInteger) max
{
   char     *s;
   size_t   len;

   s = [[NSFileManager sharedInstance] fileSystemRepresentationWithPath:self];
   if( ! s)
      return( NO);
   len = strlen( s);
   if( len > max)
      return( NO);

   memcpy( buf, s, len);
   return( YES);
}


+ (instancetype) stringWithContentsOfFile:(NSString *) path
{
   return( [[[self alloc] initWithContentsOfFile:path] autorelease]);
}



static NSStringEncoding  encodingForBOMOfData( NSData *p)
{
   struct mulle_data   data;
   mulle_utf16_t       c16;
   mulle_utf32_t       c32;
   uint8_t             *bytes;

   data = [p mulleCData];
   if( data.length >= 2)
   {
      bytes = data.bytes;
      // length must be at least 2 now
      c16   = (mulle_utf16_t) ((bytes[ 0] << 8) | bytes[ 1]);
      if( mulle_utf16_get_bomcharacter() == c16)
         return( NSUTF16BigEndianStringEncoding);

      c16   = (mulle_utf16_t) ((bytes[ 1] << 8) | bytes[ 0]);
      if( mulle_utf16_get_bomcharacter() == c16)
         return( NSUTF16LittleEndianStringEncoding);

      if( mulle_utf8_has_leading_bomcharacter( (char *) bytes, data.length))
         return( NSUTF8StringEncoding);

      if( data.length >= 4)
      {
         c32 = (mulle_utf32_t) ((bytes[ 0] << 24) |
                                (bytes[ 1] << 16) |
                                (bytes[ 2] << 8) |
                                bytes[ 3]);
         if( mulle_utf32_get_bomcharacter() == c32)
            return( NSUTF32BigEndianStringEncoding);

         c32 = (mulle_utf32_t) ((bytes[ 3] << 24) |
                                (bytes[ 2] << 16) |
                                (bytes[ 1] << 8) |
                                bytes[ 0]);
         if( mulle_utf32_get_bomcharacter() == c32)
            return( NSUTF32LittleEndianStringEncoding);
      }
   }

   return( 0);
}


- (instancetype) initWithContentsOfFile:(NSString *) path
{
   NSData             *data;
   NSStringEncoding   encoding;

   data = [NSData dataWithContentsOfFile:path];
   if( ! data)
   {
      [self release];
      return( nil);
   }

   encoding = encodingForBOMOfData( data);
   if( ! encoding)
      encoding = [NSString defaultCStringEncoding];

#if 0
   return( [self initWithData:data
                     encoding:encoding]);
#else
   return( [self mulleInitWithDataNoCopy:data
                                encoding:encoding]);
#endif
}


- (instancetype) mulleInitWithLossyContentsOfFile:(NSString *) path
{
   NSMutableData      *data;
   NSStringEncoding   encoding;

   data = [NSMutableData dataWithContentsOfFile:path];
   if( ! data)
   {
      [self release];
      return( nil);
   }

   encoding = encodingForBOMOfData( data);
   if( ! encoding)
      encoding = [NSString defaultCStringEncoding];

   /*
    * flip bytes now, if needed
    */
   switch( encoding)
   {
#ifdef __BIG_ENDIAN__
   case NSUTF16LittleEndianStringEncoding :
#endif
#ifdef __LITTLE_ENDIAN__
   case NSUTF16BigEndianStringEncoding    :
#endif
      [data mulleSwapUTF16Characters];
      encoding = NSUTF16StringEncoding;
      break;

#ifdef __BIG_ENDIAN__
   case NSUTF32LittleEndianStringEncoding :
#endif
#ifdef __LITTLE_ENDIAN__
   case NSUTF32BigEndianStringEncoding    :
#endif
      [data mulleSwapUTF32Characters];
      encoding = NSUTF32StringEncoding;
      break;
   }

   // do a lossy conversion for invalid characters
   [data mulleReplaceInvalidCharactersWithASCIICharacter:'?'
                                                encoding:encoding];

   return( [self mulleInitWithDataNoCopy:data
                                encoding:encoding]);
}


+ (instancetype) mulleStringWithLossyContentsOfFile:(NSString *) path
{
   return( [[[self alloc] mulleInitWithLossyContentsOfFile:path] autorelease]);
}



- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag
{
   NSData  *data;

   data = [self dataUsingEncoding:NSUTF8StringEncoding];
   assert( data);
   return( [data writeToFile:path
                  atomically:flag]);
}


- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag
            encoding:(NSStringEncoding) encoding
               error:(NSError **) error
{
   NSData  *data;

   data = [self dataUsingEncoding:encoding];
   return( [data writeToFile:path
                  atomically:flag
                       error:error]);
}


// complete like bash here, if the file exists and is a directory
// complete with '/', if that isn't part of the name. If it is
// use it as directory.
// Otherwise if it it doesn't exist. Use lastPath component as prefix
// and enumerate dir
//
- (NSUInteger) completePathIntoString:(NSString **) outputName
                        caseSensitive:(BOOL) flag
                     matchesIntoArray:(NSArray **) outputArray
                          filterTypes:(NSArray *) filterTypes
{
   NSFileManager           *fileManager;
   NSDirectoryEnumerator   *rover;
   NSString                *prefix;
   NSString                *directory;
   NSString                *fileName;
   NSString                *matchName;
   NSString                *extension;
   NSString                *maxName;
   id                      set;
   NSUInteger              n;
   NSUInteger              length;
   NSUInteger              maxLength;
   BOOL                    isDirectory;
   NSMutableArray          *array;


   fileManager = [NSFileManager defaultManager];
   if( [fileManager fileExistsAtPath:self
                         isDirectory:&isDirectory])
   {
      prefix    = @"";
      directory = nil;
      if( isDirectory)
      {
         if( ! [self hasSuffix:NSFilePathComponentSeparator])
         {
            if( outputName)
               *outputName = [self stringByAppendingString:NSFilePathComponentSeparator];
            if( outputArray)
               *outputArray = nil;
            return( 1);
         }
         directory = self;
      }
   }
   else
   {
      prefix    = [self lastPathComponent];
      directory = [self stringByDeletingLastPathComponent];
   }

   if( ! flag)
      prefix = [prefix lowercaseString];

   // use a set, if we have very many file extensions
   set = filterTypes;
   if( [set count] > 16)
      set = [NSSet setWithArray:filterTypes];

   maxName   = nil;
   maxLength = 0;
   n         = 0;
   array     = nil;

   rover = [fileManager enumeratorAtPath:directory];
   while( fileName = [rover nextObject])
   {
      if( set)
      {
         extension = [fileName pathExtension];
         if( ! [set containsObject:extension])
            continue;
      }

      // for matching conver to lowercase if needed
      matchName = flag ? fileName : [fileName lowercaseString];
      if( ! [matchName hasPrefix:prefix])
         continue;

      if( outputArray && ! array)
         array = [NSMutableArray array];
      [array addObject:fileName];
      ++n;

      length = [fileName length];
      if( length > maxLength)
      {
         maxName   = fileName;
         maxLength = length;
      }
   }

   if( outputName)
      *outputName = maxName;
   if( outputArray)
      *outputArray = array;
   return( n);
}

@end

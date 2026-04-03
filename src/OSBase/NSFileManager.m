/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSFileManager.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "NSFileManager.h"

// other files in this library
#import "NSData+OSBase.h"
#import "NSDirectoryEnumerator.h"
#import "NSString+OSBase.h"
#import "NSPageAllocation.h"

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies


MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileAppendOnly            = @"NSFileAppendOnly";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileBusy                  = @"NSFileBusy";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileCreationDate          = @"NSFileCreationDate";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileDeviceIdentifier      = @"NSFileDeviceIdentifier";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileExtensionHidden       = @"NSFileExtensionHidden";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileGroupOwnerAccountID   = @"NSFileGroupOwnerAccountID";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileGroupOwnerAccountName = @"NSFileGroupOwnerAccountName";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileHFSCreatorCode        = @"NSFileHFSCreatorCode";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileHFSTypeCode           = @"NSFileHFSTypeCode";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileImmutable             = @"NSFileImmutable";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileModificationDate      = @"NSFileModificationDate";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileOwnerAccountID        = @"NSFileOwnerAccountID";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileOwnerAccountName      = @"NSFileOwnerAccountName";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFilePosixPermissions      = @"NSFilePosixPermissions";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileReferenceCount        = @"NSFileReferenceCount";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileSize                  = @"NSFileSize";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileSystemFileNumber      = @"NSFileSystemFileNumber";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileSystemNumber          = @"NSFileSystemNumber";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileType                  = @"NSFileType";

MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileTypeBlockSpecial     = @"NSFileTypeBlockSpecial";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileTypeCharacterSpecial = @"NSFileTypeCharacterSpecial";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileTypeDirectory        = @"NSFileTypeDirectory";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileTypePipe             = @"NSFileTypePipe";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileTypeRegular          = @"NSFileTypeRegular";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileTypeSocket           = @"NSFileTypeSocket";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileTypeSymbolicLink     = @"NSFileTypeSymbolicLink";
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString   *NSFileTypeUnknown          = @"NSFileTypeUnknown";


@interface NSDirectoryEnumerator ( NSFileManager)

- (instancetype) initWithFileManager:(NSFileManager *) manager
                            rootPath:(NSString *) root
                       inheritedPath:(NSString *) inherited;
- (instancetype) initWithFileManager:(NSFileManager *) manager
                           directory:(NSString *) path;

@end


@implementation NSFileManager

+ (NSFileManager *) defaultManager
{
   return( [self sharedInstance]);
}


- (NSDirectoryEnumerator *) enumeratorAtPath:(NSString *) path
{
   return( [[[NSDirectoryEnumerator alloc] initWithFileManager:self
                                                     directory:path] autorelease]);
}


- (void) dealloc
{
   [super dealloc];
}


// useless fluff routines
- (BOOL) createFileAtPath:(NSString *) path
                 contents:(NSData *) contents
               attributes:(NSDictionary *) attributes
{
   BOOL      flag;
   NSError   *error;

   if( ! [contents writeToFile:path
                      atomically:NO])
      return( NO);

   flag = [self setAttributes:attributes
                 ofItemAtPath:path
                        error:&error];
   return( flag);
}


- (NSData *) contentsAtPath:(NSString *) path
{
   return( [NSData dataWithContentsOfFile:path]);
}


- (BOOL) contentsEqualAtPath:(NSString *) path1
                     andPath:(NSString *) path2
{
   NSData  *data1;
   NSData  *data2;

   data1 = [NSData dataWithContentsOfFile:path1];
   data2 = [NSData dataWithContentsOfFile:path2];
   return( [data1 isEqualToData:data2]);
}


- (BOOL) _removeDirectoryAtPath:(NSString *) path
{
   NSArray   *contents;
   NSString  *name;
   NSString  *itemPath;

   contents = [self directoryContentsAtPath:path];
   for( name in contents)
   {
      itemPath = [path stringByAppendingPathComponent:name];
      if( ! [self removeItemAtPath:itemPath])
      {
         if( [_delegate respondsToSelector:@selector(fileManager:shouldProceedAfterError:removingItemAtPath:)])
            if( ! [_delegate fileManager:self
                shouldProceedAfterError:[NSError mulleExtract]
                     removingItemAtPath:path])
               return( NO);
      }
   }

   return( [self _removeEmptyDirectoryItemAtPath:path]);
}


- (BOOL) removeItemAtPath:(NSString *) path
{
   BOOL   flag;
   BOOL   isDirectory;

   if( ! [self fileExistsAtPath:path
                    isDirectory:&isDirectory])
      return( NO);

   if( [_delegate respondsToSelector:@selector( fileManager:shouldRemoveItemAtPath:)])
      if( ! [_delegate fileManager:self
          shouldRemoveItemAtPath:path])
         return( NO);

   if( isDirectory)
      flag = [self _removeDirectoryAtPath:path];
   else
      flag = [self _removeFileAtPath:path];

   return( flag);
}


- (BOOL) removeItemAtPath:(NSString *) path
                    error:(NSError **) error
{
   if( ! [self removeItemAtPath:path] && error)
   {
      *error = [NSError mulleExtract];
      return( NO);
   }

   return( YES);
}


- (BOOL) removeFileAtPath:(NSString *) path
                  handler:(id) handler
{
    if( [handler respondsToSelector:@selector( fileManager:willProcessPath:)])
        [handler fileManager:self
             willProcessPath:path];

    return( [self removeItemAtPath:path
                             error:NULL]);
}


- (BOOL) createDirectoryAtPath:(NSString *) path
                    attributes:(NSDictionary *) attributes
{
   return( [self createDirectoryAtPath:path
           withIntermediateDirectories:NO
                            attributes:attributes
                                 error:NULL]);
}


- (BOOL) createSymbolicLinkAtPath:(NSString *) path
                      pathContent:(NSString *) otherpath
{
   return( [self createSymbolicLinkAtPath:path
                      withDestinationPath:otherpath
                                    error:NULL]);
}

@end


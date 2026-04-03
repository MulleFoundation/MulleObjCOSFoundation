/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSFileManager.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "import.h"


@class NSDirectoryEnumerator;


//
// General wording:
//
// An `Item` is either a `Directory` or a `SymbolicLink` or a `File`
// (incl. special Files, like devices)
//
@class NSFileManager;

@protocol NSFileManagerHandler

@optional
- (void)  fileManager:(NSFileManager *) fileManager
      willProcessPath:(NSString *) path;

@end


@protocol NSFileManagerDelegate

@optional

- (BOOL) fileManager:(NSFileManager *) fileManager
shouldRemoveItemAtPath:(NSString *) path;

- (BOOL) fileManager:(NSFileManager *) fileManager
shouldMoveItemAtPath:(NSString *) srcPath
              toPath:(NSString *) dstPath;

- (BOOL) fileManager:(NSFileManager *)fileManager
 shouldMoveItemAtPath:(NSString *) srcPath
               toPath:(NSString *) dstPath;

- (BOOL) fileManager:(NSFileManager *) fileManager
shouldCopyItemAtPath:(NSString *) srcPath
              toPath:(NSString *) dstPath;

- (BOOL) fileManager:(NSFileManager *) fileManager
shouldProceedAfterError:(NSError *) error
  removingItemAtPath:(NSString *) path;

- (BOOL) fileManager:(NSFileManager *) fileManager
shouldProceedAfterError:(NSError *)error
   copyingItemAtPath:(NSString *) srcPath
              toPath:(NSString *) dstPath;

- (BOOL) fileManager:(NSFileManager *) fileManager
shouldLinkItemAtPath:(NSString *) srcPath
              toPath:(NSString *) dstPath;

- (BOOL) fileManager:(NSFileManager *) fileManager
shouldProceedAfterError:(NSError *) error
   linkingItemAtPath:(NSString *) srcPath
              toPath:(NSString *) dstPath;

- (BOOL)fileManager:(NSFileManager *)fileManager
shouldProceedAfterError:(NSError *)error
   movingItemAtPath:(NSString *)srcPath
             toPath:(NSString *)dstPath;
@end


//
// ThreadSafety
//
// The NSFileManager's methods can be invoked from various threads without
// issues. Nonetheless, if you're employing a delegate to monitor the outcomes
// of move, copy, delete, and link actions, it's advisable to instantiate a
// separate file manager object, appoint your delegate to this instance, and
// then utilize this file manager for executing your operations.
//
//
@interface NSFileManager : NSObject < MulleObjCSingleton, MulleObjCThreadSafe>

@property( assign) id   delegate;

+ (NSFileManager *) defaultManager;

- (NSDirectoryEnumerator *) enumeratorAtPath:(NSString *) path;

// useless fluff routines
- (BOOL) createFileAtPath:(NSString *) path
                 contents:(NSData *) contents
               attributes:(NSDictionary *)attributes;


- (NSData *) contentsAtPath:(NSString *) path;
- (BOOL) contentsEqualAtPath:(NSString *) path1
                     andPath:(NSString *) path2;

- (BOOL) removeFileAtPath:(NSString *) path
                  handler:(id) handler;


// Apple deprecates, Mulle supports
- (BOOL) createDirectoryAtPath:(NSString *)path
                    attributes:(NSDictionary *)attributes;

- (BOOL) createSymbolicLinkAtPath:(NSString *) path
                      pathContent:(NSString *) otherpath;
@end


@interface NSFileManager (Future)

- (char *) fileSystemRepresentationWithPath:(NSString *) path;
- (NSString *) stringWithFileSystemRepresentation:(char *) s
                                           length:(NSUInteger) len;

- (BOOL) changeCurrentDirectoryPath:(NSString *) path;
- (NSString *) currentDirectoryPath;
- (BOOL) fileExistsAtPath:(NSString *) path;
- (BOOL) fileExistsAtPath:(NSString *) path
              isDirectory:(BOOL *) isDirectory;
- (BOOL) isDeletableFileAtPath:(NSString *) path;
- (BOOL) isExecutableFileAtPath:(NSString *) path;
- (BOOL) isReadableFileAtPath:(NSString *) path;
- (BOOL) isWritableFileAtPath:(NSString *) path;

- (BOOL) createSymbolicLinkAtPath:(NSString *) path
              withDestinationPath:(NSString *) otherpath
                            error:(NSError **) error;

- (BOOL) createDirectoryAtPath:(NSString *) path
   withIntermediateDirectories:(BOOL) createIntermediates
                    attributes:(NSDictionary *) attributes
                         error:(NSError **) error;


- (NSString *) pathContentOfSymbolicLinkAtPath:(NSString *) path;
- (NSArray *) directoryContentsAtPath:(NSString *) path;

- (NSDictionary *) fileSystemAttributesAtPath:(NSString *) path;

// TODO: why is this not named fileSystemAttributesAtPath:traverseLink: ?
- (NSDictionary *) fileAttributesAtPath:(NSString *) path
                           traverseLink:(BOOL) flag;

// TODO: why u no nem sis setFileSystemAttributesAtPath: ??
// MEMO: some stuff is missing like:
// - attributesOfItemAtPath:error:
// - attributesOfFileSystemForPath:error:
//
- (BOOL) setAttributes:(NSDictionary *) attributes
          ofItemAtPath:(NSString *) path
                 error:(NSError **) error;

- (int) _createDirectoryAtPath:(NSString *) path
                    attributes:(NSDictionary *) attributes;

- (BOOL) _removeFileAtPath:(NSString *) path;
- (BOOL) _removeEmptyDirectoryItemAtPath:(NSString *) path;
- (BOOL) removeItemAtPath:(NSString *) path
                    error:(NSError **) error;

- (BOOL) movePath:(NSString *) src
           toPath:(NSString *) dest
          handler:(id) handler;
- (BOOL) copyPath:(NSString *) src
           toPath:(NSString *) dest
          handler:(id) handler;

- (BOOL) moveItemAtPath:(NSString *) srcPath
                 toPath:(NSString *) dstPath
                  error:(NSError **) error;
- (BOOL) copyItemAtPath:(NSString *) fromPath
                 toPath:(NSString *) toPath
                  error:(NSError **) error;

@end


MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileType;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileSize;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileModificationDate;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileReferenceCount;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileDeviceIdentifier;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileOwnerAccountName;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileGroupOwnerAccountName;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFilePosixPermissions;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileSystemNumber;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileSystemFileNumber;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileExtensionHidden;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileHFSCreatorCode;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileHFSTypeCode;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileImmutable;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileAppendOnly;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileCreationDate;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileOwnerAccountID;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileGroupOwnerAccountID;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileBusy;

MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileTypeDirectory;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileTypePipe;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileTypeRegular;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileTypeSymbolicLink;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileTypeSocket;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileTypeCharacterSpecial;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileTypeBlockSpecial;
MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL NSString   *NSFileTypeUnknown;


// Cross-DLL Global Variable Declaration/Definition Mismatch
//
// Scenario: OSBase library declares global variables in its header.
// The Windows library (a separate DLL) provides the actual definitions.
//
// The Problem:
//
// 1. The OSBase header declares:
//
// ```c
// MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL
// NSString *NSFilePathComponentSeparator;
// ```
//
// but the actual implementation is deferred to another subproject.
//
// - When compiling OSBase: expands to __declspec(dllexport) - "I export this".
//   For code accessing this variable _from_ OSBase, it's a **mismatch**
// - When compiling other code: expands to __declspec(dllimport) -
//   "Import from DLL" - correct
//
// 2. Then in the Windows .m we define:
//
// ```c
// MULLE_OBJC_WINDOWS_FOUNDATION_GLOBAL_VAR
// NSString *NSFilePathComponentSeparator = @"/";
// ```
// - The OSBase decl Expands to __declspec(dllimport), this is now a **mismatch**
// - Our MULLE_OBJC_WINDOWS_FOUNDATION_GLOBAL_VAR expands to __declspec(dllexport) - correct
//
// 3. User code includes OSBase header:
//
// Sees dllimport from DLL - correct
//
// Solution:
// For everybody except those defining
// MULLE_OBJC_OS_BASE_GLOBAL_FUTURE_IMPLEMENTATION
// this is a dllimport (including OSBase).
//
// For implementors (they need to implement all globals here) defining
// MULLE_OBJC_OS_BASE_GLOBAL_FUTURE_IMPLEMENTATION all this is not visible.
// Which is good, because it catches misuse early. So declare these globals
// in the implementor in a private header. (And define in .m of course)
//
// The Windows loader doesn't resolve __imp_ symbols. It resolves import
// directory entries. And NSFilePathComponentSeparator has no import directory
// entry in libMulleObjCOSBaseFoundation.dll - we proved that earlier.
//
// LATER: WHY THIS DONT WORK
//
// 1. The compiler saw __declspec(dllimport)
//    NSString *NSFilePathComponentSeparator and generated code that accesses
//    the variable through an __imp_NSFilePathComponentSeparator pointer
//    (an indirect load).
//
// 2. Normally the linker would find __imp_NSFilePathComponentSeparator in an
//    import library (.dll.a) and bind it to a specific DLL's import table.
//
// 3. But here, no import library for libMulleObjCWindowsFoundation.dll was
//    provided at link time of libMulleObjCOSBaseFoundation.dll. So the linker
//    left __imp_NSFilePathComponentSeparator as an unresolved external (sec -1).
//
// This means at runtime, accessing NSFilePathComponentSeparator from
// libMulleObjCOSBaseFoundation.dll will crash (or never happen because the
// code path is avoided). The Windows PE loader won't fix this up - it only
// resolves what's in the import directory table.
//
//

// irony: not even global variables anymore
#define NSFilePathComponentSeparator @"/"
#define NSFilePathExtensionSeparator @"."

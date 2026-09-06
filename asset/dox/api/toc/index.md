# MulleObjCOSFoundation Library Documentation for AI
<!-- Keywords: filesystem, process, pipe, runloop, bundle, os, platform -->

## 1. Introduction & Purpose

MulleObjCOSFoundation provides platform-dependent Objective-C classes and
categories for operating-system interaction. It builds on top of
MulleObjCStandardFoundation (via `MulleObjC`) and supplies the OS-specific
layer that is missing there: filesystem management (`NSFileManager`,
`NSDirectoryEnumerator`, `NSFileHandle`), process management (`NSTask`),
inter-process communication (`NSPipe`), process/environment metadata
(`NSProcessInfo`), preferences (`NSUserDefaults`), event-loop handling
(`NSRunLoop`, in POSIX a wrapper around `select(2)`), plugin/dynamic-library
loading (`NSBundle`), and platform C-string utilities (`NSString+CString`).

The library is a core dependency of the MulleFoundation object system. It
builds differently on each platform: the `src/OSBase` subproject contains
the portable core, while `src/Posix`, `src/BSD`, `src/FreeBSD`, `src/Darwin`,
`src/Linux`, and `src/Windows` provide the platform-specific implementations
that are selected at build time.

## 2. Key Concepts & Design Philosophy

- **Platform Abstraction**: OS-specific behavior is hidden behind the unified
  `NS*` API. For instance `NSHomeDirectory()` is dispatched through a vector
  table (`_NSPathUtilityVectorTable`) that each platform overrides, and
  `NSFileManager` maps onto POSIX or Windows APIs.
- **Separate Subprojects**: The library is composed of per-platform
  subprojects (`OSBase`, `Posix`, `BSD`, `Darwin`, `Linux`, `Windows`,
  `FreeBSD`). Only the applicable ones are compiled for a given platform
  (e.g. `BSD` is excluded on Linux/Android/Windows, `Darwin` only on macOS).
- **Singletons**: Core services are exposed as thread-safe singletons
  (`NSFileManager`, `NSProcessInfo`, `NSUserDefaults`) via the
  `MulleObjCSingleton` protocol.
- **Future/Constructive API**: Many classes declare additional methods in
  `<ClassName>(Future)` categories bound by the `MulleObjCFuture` protocol.
  These are real, callable APIs provided for forward-compatibility; they are
  not "optional" stubs.
- **Error Handling**: File operations return `BOOL` or `NSData *`; the
  `Future` variants additionally accept `NSError **` out-parameters and use
  the POSIX/Windows error domains (e.g. `NSPOSIXErrorDomain`).
- **Native Encoding**: `NSString+CString` adds conversion to/from the platform
  native C string encoding (`char *`), and `NSString+FileSystemString` /
  `NSString+Windows` convert between Unix and Windows path separators.

## 3. Core API & Data Structures

### 3.1. `NSFileManager.h` — Filesystem operations

`NSFileManager` is the primary entry point for filesystem management. All
methods are thread-safe; if you use a delegate for move/copy/delete/link
callbacks you should use a dedicated instance for that operation.

#### Protocols

- `@protocol NSFileManagerHandler` (optional): `- (void) fileManager:(NSFileManager *) fileManager willProcessPath:(NSString *) path;`
- `@protocol NSFileManagerDelegate` (optional): `shouldRemoveItemAtPath:`,
  `shouldMoveItemAtPath:toPath:`, `shouldCopyItemAtPath:toPath:`,
  `shouldLinkItemAtPath:toPath:`, and `shouldProceedAfterError:...` variants
  for removal/copying/linking/moving.

#### Singleton + File Operations

```objc
+ (NSFileManager *) defaultManager;
- (NSDirectoryEnumerator *) enumeratorAtPath:(NSString *) path;
- (BOOL) createFileAtPath:(NSString *) path
                 contents:(NSData *) contents
               attributes:(NSDictionary *)attributes;
- (NSData *) contentsAtPath:(NSString *) path;
- (BOOL) contentsEqualAtPath:(NSString *) path1
                     andPath:(NSString *) path2;
- (BOOL) removeFileAtPath:(NSString *) path
                  handler:(id) handler;
- (BOOL) createDirectoryAtPath:(NSString *)path
                    attributes:(NSDictionary *)attributes;
- (BOOL) createSymbolicLinkAtPath:(NSString *) path
                      pathContent:(NSString *) otherpath;
- (BOOL) movePath:(NSString *) src
           toPath:(NSString *) dest
          handler:(id) handler;
- (BOOL) copyPath:(NSString *) src
           toPath:(NSString *) dest
          handler:(id) handler;
```

#### `NSFileManager(Future)` — error-returning variants and state queries

```objc
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
- (NSDictionary *) fileAttributesAtPath:(NSString *) path
                           traverseLink:(BOOL) flag;
- (BOOL) setAttributes:(NSDictionary *) attributes
          ofItemAtPath:(NSString *) path
                 error:(NSError **) error;
- (BOOL) removeItemAtPath:(NSString *) path
                    error:(NSError **) error;
- (BOOL) moveItemAtPath:(NSString *) srcPath
                 toPath:(NSString *) dstPath
                  error:(NSError **) error;
- (BOOL) copyItemAtPath:(NSString *) fromPath
                 toPath:(NSString *) toPath
                  error:(NSError **) error;
```

#### File Attribute Keys

Global `NSString *` constants for attribute dictionaries: `NSFileType`,
`NSFileSize`, `NSFileModificationDate`, `NSFileReferenceCount`,
`NSFileDeviceIdentifier`, `NSFileOwnerAccountName`,
`NSFileGroupOwnerAccountName`, `NSFilePosixPermissions`, `NSFileSystemNumber`,
`NSFileSystemFileNumber`, `NSFileExtensionHidden`, `NSFileHFSCreatorCode`,
`NSFileHFSTypeCode`, `NSFileImmutable`, `NSFileAppendOnly`,
`NSFileCreationDate`, `NSFileOwnerAccountID`, `NSFileGroupOwnerAccountID`,
`NSFileBusy`, plus `NSFileTypeDirectory`/`Pipe`/`Regular`/`SymbolicLink`/
`Socket`/`CharacterSpecial`/`BlockSpecial`/`Unknown` value constants. On
Windows these globals are declared by the OSBase header but defined by the
Windows subproject. `NSFilePathComponentSeparator` is `@"/"` and
`NSFilePathExtensionSeparator` is `@"."`.

### 3.2. `NSDirectoryEnumerator.h` — directory traversal

`NSDirectoryEnumerator` (subclass of `NSEnumerator`) lets you walk directory
contents depth-first. `nextObject` returns relative paths; returns `nil` at
end. It also provides `- (NSDictionary *) directoryAttributes;` and
`- (NSDictionary *) fileAttributes;` for the current entry.

```objc
- (NSDictionary *) directoryAttributes;
- (NSDictionary *) fileAttributes;
- (NSUInteger) level;
- (void) skipDescendants;
// Future:
- (instancetype) initWithFileManager:(NSFileManager *) manager
                            rootPath:(NSString *) root
                       inheritedPath:(NSString *) inherited;
```

### 3.3. `NSFileHandle.h` — low-level file I/O

`NSFileHandle` wraps a file descriptor (or a Windows `HANDLE`, held in the
`void *_fd` field). It conforms to `MulleObjCInputStream`,
`MulleObjCOutputStream`, `MulleObjCThreadSafe`. A single handle should only
be accessed from one thread; the underlying fd is a separate concern.

```objc
+ (instancetype) fileHandleForReadingAtPath:(NSString *) path;
+ (instancetype) fileHandleForWritingAtPath:(NSString *) path;
+ (instancetype) fileHandleForUpdatingAtPath:(NSString *) path;
+ (instancetype) fileHandleWithNullDevice;
- (instancetype) initWithFileDescriptor:(int) fd;
- (NSData *) availableData;
- (NSData *) readDataToEndOfFile;
- (NSData *) readDataOfLength:(NSUInteger) length;
- (unsigned long long) offsetInFile;
- (unsigned long long) seekToEndOfFile;
- (void) seekToFileOffset:(unsigned long long) offset;
- (void) truncateFileAtOffset:(unsigned long long) offset;
- (void) writeData:(NSData *) data;
- (NSInteger) fileDescriptor;
- (void) closeFile;   // does -finalize
- (void) mulleWriteBytes:(void *) bytes
                  length:(NSUInteger) len;   // len == -1 means strlen(bytes)
```

`NSFileHandle(SubclassFuture)` adds standard file handles
`+ fileHandleWithStandardInput`/`Output`/`Error`,
`- initWithFileDescriptor:(int) fd closeOnDealloc:(BOOL) flag;`,
`- synchronizeFile;` and the low-level open/read/write/seek hooks. State bits
`enum NSFileHandleStateBit` (EOF, Pipe, Again) are accessed via
`- mulleGetStateBits`/`- mulleAddToStateBits:`. The global
`NSString *NSFileHandleOperationException` names the exception raised on
zero-length reads at EOF. `NSNullDeviceFileHandle` is a discard-all output
handle.

`NSFileHandle(NSRunLoop)` (in `NSFileHandle+NSRunLoop.h`) adds
`- (void) readInBackgroundAndNotify;` and
`- (void) readInBackgroundAndNotifyForModes:(NSArray *) modes;` plus the
notification-name globals `NSFileHandleConnectionAcceptedNotification`,
`NSFileHandleDataAvailableNotification`,
`NSFileHandleReadToEndOfFileCompletionNotification`,
`NSFileHandleReadCompletionNotification`,
`NSFileHandleNotificationDataItem`, `NSFileHandleNotificationFileHandleItem`.

### 3.4. `NSPipe.h` — inter-process communication

```objc
+ (instancetype) pipe;
- (NSFileHandle *) fileHandleForReading;
- (NSFileHandle *) fileHandleForWriting;
- (NSInteger) _fileDescriptorForReading;
- (NSInteger) _fileDescriptorForWriting;
```

### 3.5. `NSTask.h` — process management

`NSTask` launches a subprocess. It is configured first (launch path,
arguments, working directory, environment, standard I/O), then launched.

```objc
enum
{
   NSTaskTerminationReasonExit           = 1,
   NSTaskTerminationReasonUncaughtSignal = 2
};
typedef NSInteger   NSTaskTerminationReason;

+ (NSTask *) launchedTaskWithLaunchPath:(NSString *) path
                              arguments:(NSArray *) arguments;
- (void) setArguments:(NSArray *) arguments;
- (void) setCurrentDirectoryPath:(NSString *) path;
- (void) setEnvironment:(NSDictionary *) environmentDictionary;
- (void) setLaunchPath:(NSString *) path;
- (void) setStandardError:(id) file;
- (void) setStandardInput:(id) file;
- (void) setStandardOutput:(id) file;
- (NSInteger) processIdentifier;
- (NSInteger) terminationStatus;
- (id) standardError;
- (id) standardInput;
- (id) standardOutput;
- (NSArray *) arguments;
- (NSString *) launchPath;
- (NSString *) currentDirectoryPath;
- (NSDictionary *) environment;
// NSTask(Future):
- (BOOL) isRunning;
- (void) interrupt;
- (void) launch;
- (BOOL) resume;
- (BOOL) suspend;
- (void) terminate;
- (void) waitUntilExit;
- (NSTaskTerminationReason) terminationReason;
```

Note: standard I/O setters accept `id` — pass `NSPipe` or `NSFileHandle`.

#### `NSTask(System)` — convenient system-call helpers

`enum NSTaskSystemOptions` (`NSTaskSystemSendStandardInput`,
`NSTaskSystemReceiveStandardOutput`, `NSTaskSystemReceiveStandardError`)
controls which streams are captured. Returns an `NSDictionary` keyed by:

`NSTaskExceptionKey`, `NSTaskTerminationStatusKey`,
`NSTaskStandardOutputDataKey`, `NSTaskStandardOutputStringKey`,
`NSTaskStandardErrorDataKey`, `NSTaskStandardErrorStringKey`.

Key class methods:

```objc
+ (NSDictionary *) mulleDataSystemCallWithArguments:(NSArray *) argv
                                        environment:(NSDictionary *) environment
                                   workingDirectory:(NSString *) dir
                                  standardInputData:(NSData *) inputData
                                            options:(NSTaskSystemOptions) options;
+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv
                                  standardInputString:(NSString *) stdinString;
+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s;
```

The `*String*` variants are like the `*Data*` variants but use `NSString`
and flatten exceptions (terminationStatus `-1`, reason in stdout). The
`CommandString` variants parse the string into an argument array. This
category is a good deadlock-free alternative to raw pipes because it reads
stdout/stderr while the process runs.

### 3.6. `NSProcessInfo.h` — process & environment metadata

```objc
enum
{
   NSWindowsNTOperatingSystem = 1,
   NSWindows95OperatingSystem,
   NSSolarisOperatingSystem,
   NSHPUXOperatingSystem,
   NSDarwinOperatingSystem,
   NSSunOSOperatingSystem,
   NSOSF1OperatingSystem,
   NSLinuxOperatingSystem,
   NSBSDOperatingSystem
};

+ (NSProcessInfo *) processInfo;
// NSProcessInfo(Future):
- (NSString *) hostName;
- (NSUInteger) operatingSystem;
- (NSString *) operatingSystemName;
- (NSString *) operatingSystemVersionString;
- (NSArray *) arguments;
- (NSDictionary *) environment;
- (NSString *) processName;
- (void) setProcessName:(NSString *) name;
- (NSString *) globallyUniqueString;
- (NSInteger) processIdentifier;
- (void) mulleSetEnvironmentValue:(NSString *) value
                           forKey:(NSString *) key;   // calls setenv(2)
```

`_executablePath` is private but implemented; use it with caution.

### 3.7. `NSUserDefaults.h` — preferences storage

This is a Darwin concept; on Linux it maps to `~/.config`, on Windows to the
registry.

```objc
+ (NSUserDefaults *)  standardUserDefaults;
- (instancetype) init;
- (id) objectForKey:(id) key;
- (void) setObject:(id) value
            forKey:(id <NSObject, MulleObjCImmutableCopying>) key;
- (void) removeObjectForKey:(id) key;
- (void) registerDefaults:(NSDictionary *) registrationDictionary;
- (NSDictionary *) dictionaryRepresentation;
- (BOOL) synchronize;
// Future:
+ (void) resetStandardUserDefaults;
```

`NSUserDefaults(Conveniences)` provides typed accessors:
`boolForKey:`, `doubleForKey:`, `floatForKey:`, `arrayForKey:`,
`stringArrayForKey:`, `dataForKey:`, `dictionaryForKey:`, `integerForKey:`,
`stringForKey:` and setters `setInteger:forKey:`, `setFloat:forKey:`,
`setDouble:forKey:`, `setBool:forKey:` (each taking `(NSString *) key`).
Global domains: `NSGlobalDomain`, `NSArgumentDomain`, `NSRegistrationDomain`.

### 3.8. `NSRunLoop.h` — event loop

`NSRunLoop` is usually a wrapper around `select(2)` on POSIX. It exists per
thread and should not be shared across threads. `NSRunLoopMode` is a typedef
for `NSString *`; `NSDefaultRunLoopMode` is predefined. Tuning types
`struct MulleRunLoopMessage`, `struct MulleRunLoopMessageArray` and
`struct MulleRunLoopMode` are exposed but used internally.

```objc
+ (NSRunLoop *) currentRunLoop;
+ (NSRunLoop *) mainRunLoop;
+ (NSRunLoop *) mulleCurrentRunLoop;   // may return nil during teardown
- (NSRunLoopMode) currentMode;
- (void) acceptInputForMode:(NSRunLoopMode) modeName
                 beforeDate:(NSDate *) limitDate;
- (void) run;
- (void) runUntilDate:(NSDate *) limitDate;
- (BOOL) runMode:(NSRunLoopMode) modeName
      beforeDate:(NSDate *) limitDate;
- (NSDate *) limitDateForMode:(NSRunLoopMode) modeName;
- (void) performSelector:(SEL) aSelector
                  target:(id) target
                argument:(id) arg
                   order:(NSUInteger) order
                   modes:(NSArray *) modes;
- (void) cancelPerformSelector:(SEL) aSelector
                        target:(id) target
                      argument:(id) arg;
- (void) cancelPerformSelectorsWithTarget:(id) target;
- (void) addTimer:(NSTimer *) timer
          forMode:(NSRunLoopMode) modeName;
```

#### Related categories

- `NSObject(NSRunLoop)` (`NSObject+NSRunLoop.h`):
  `- performSelector:withObject:afterDelay:inModes:` and
  `- performSelector:withObject:afterDelay:`, plus class methods
  `+ cancelPreviousPerformRequestsWithTarget:` and
  `+ cancelPreviousPerformRequestsWithTarget:selector:object:`.
- `NSTimer(NSRunLoop)` (`NSTimer+NSRunLoop.h`):
  `+ scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:`,
  `+ scheduledTimerWithTimeInterval:invocation:repeats:`, `- invalidate`.

### 3.9. `NSBundle.h` — bundles, plugins & localized resources

```objc
+ (NSBundle *) mainBundle;
+ (NSArray *) allFrameworks;
+ (NSArray *) allBundles;
+ (NSBundle *) bundleWithPath:(NSString *) path;
+ (NSBundle *) bundleWithIdentifier:(NSString *) identifier;
- (instancetype) initWithPath:(NSString *) fullPath;
- (NSString *) bundleIdentifier;
- (Class) principalClass;
- (NSString *) resourcePath;
- (NSString *) executablePath;
- (NSString *) bundlePath;
- (BOOL) isLoaded;
- (NSString *) pathForResource:(NSString *) name
                        ofType:(NSString *) extension;
- (NSString *) pathForResource:(NSString *) name
                        ofType:(NSString *) extension
                   inDirectory:(NSString *) subpath;
- (NSArray *) pathsForResourcesOfType:(NSString *) extension
                          inDirectory:(NSString *) subpath;
- (Class) classNamed:(NSString *) className;
- (NSString *) localizedStringForKey:(NSString *) key
                               value:(NSString *) comment
                               table:(NSString *) tableName;
- (id) objectForInfoDictionaryKey:(NSString *) key;
- (NSDictionary *) infoDictionary;
- (NSString *) developmentLocalization;
// NSBundle(OSSpecificFuture): - (BOOL) loadBundle; - (BOOL) unloadBundle;
//                              + (NSBundle *) bundleForClass:(Class) aClass;
// NSBundle(MulleSymbolLookup):
//   - (void *) mulleLookupSymbolUTF8String:(char *) name;
//   - (void *) mulleLookupSymbol:(NSString *) name;
```

Localization macros: `NSLocalizedString(key, comment)`,
`NSLocalizedStringFromTable(key, table, comment)`,
`NSLocalizedStringFromTableInBundle(key, table, bundle, comment)`,
`NSLocalizedStringWithDefaultValue(key, table, bundle, value, comment)` —
all funnel through
`MulleObjCBundleLocalizedStringFromTable(bundle, tableName, key, value)`.
Globals: `NSLoadedClasses`, `NSBundleDidLoadNotification`, function pointers
`NSBundleGetOrRegisterBundleWithPath` / `NSBundleDeregisterBundleWithPath`.

### 3.10. `Functions/NSLog.h` — logging

```objc
void   NSLog( NSString *format, ...);
void   NSLogv( NSString *format, va_list args);
void   NSLogArguments( NSString *format, mulle_vararg_list args);
```

`NSLog` prints a timestamped message to stderr. It is declared in the Posix
and Windows subprojects (each guarded per-platform), not in OSBase.

### 3.11. `Functions/NSPathUtilities.h` — path & directory utilities

```objc
enum { NSUserDomainMask=1, NSLocalDomainMask=2, NSNetworkDomainMask=4,
       NSSystemDomainMask=8, NSAllDomainsMask=~0 };
typedef NSUInteger   NSSearchPathDomainMask;

enum { NSApplicationDirectory=1, NSAdminApplicationDirectory,
       NSApplicationSupportDirectory, NSCachesDirectory, NSDesktopDirectory,
       NSDeveloperApplicationDirectory, NSDeveloperDirectory,
       NSDocumentationDirectory, NSDocumentDirectory, NSLibraryDirectory,
       NSMoviesDirectory, NSMusicDirectory, NSPicturesDirectory,
       NSSharedPublicDirectory, NSTrashDirectory, NSUserDirectory,
       NSAllApplicationsDirectory, NSAllLibrariesDirectory, };
typedef NSUInteger NSSearchPathDirectory;

NSString  *NSFullUserName( void);
NSString  *NSHomeDirectory( void);
NSString  *NSHomeDirectoryForUser( NSString *userName);
NSString  *NSOpenStepRootDirectory( void);
NSArray   *NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory directory,
                                                NSSearchPathDomainMask domainMask,
                                                BOOL expandTilde);
NSString  *NSTemporaryDirectory( void);
NSString  *NSUserName( void);
```

### 3.12. `Functions/NSPageAllocation.h` — page-granular memory

```objc
void   *NSAllocateMemoryPages( NSUInteger size);
void   NSDeallocateMemoryPages( void *ptr, NSUInteger size);
NSUInteger   NSPageSize( void);
NSUInteger   NSLogPageSize( void);
static inline NSUInteger NSRoundDownToMultipleOfPageSize(NSUInteger bytes);
static inline NSUInteger NSRoundUpToMultipleOfPageSize( NSUInteger bytes);
```

### 3.13. Categories

- `NSString(CString)` (`Categories/NSString+CString.h`): native C-string
  conversion. Constructors `+ stringWithCString:` /
  `+ stringWithCString:length:`; initializers
  `- initWithCString:length:`, `- initWithCString:`,
  `- initWithCStringNoCopy:length:freeWhenDone:`; writers
  `- getCString:`, `- getCString:maxLength:`, `- getCString:maxLength:encoding:`,
  `- getCString:maxLength:range:remainingRange:`. In `(CStringFuture)`:
  `- cStringLength`, `+ defaultCStringEncoding`, `- cString`.
- `NSString(OSBase)` (`Categories/NSString+OSBase.h`): path manipulation
  (`+ pathWithComponents:`, `- isAbsolutePath`, `- lastPathComponent`,
  `- pathExtension`, `- stringByAppendingPathComponent:`,
  `- stringByAppendingPathExtension:`, `- stringByDeletingLastPathComponent`,
  `- stringByDeletingPathExtension`, `- stringByExpandingTildeInPath`,
  `- stringByResolvingSymlinksInPath`, `- stringByStandardizingPath`,
  `- pathComponents`, `- fileSystemRepresentation`,
  `- getFileSystemRepresentation:maxLength:`), file I/O
  (`+ stringWithContentsOfFile:`, `- writeToFile:atomically:`,
  `- writeToFile:atomically:encoding:error:`,
  `- mulleInitWithLossyContentsOfFile:` — lossy decoding replaces invalid
  bytes with `?`, `- mulleStringBySimplifyingPath`), and
  `- completePathIntoString:caseSensitive:matchesIntoArray:filterTypes:`.
- `NSString(FileSystemString)` (OSBase) / `NSString(Windows)` (Windows):
  `- mulleUnixFileSystemString` and `- mulleWindowsFileSystemString` convert
  between separator conventions (identity on the native platform).
- `NSData(OSBase)` / `NSData(OSBaseFuture)`: `+ dataWithContentsOfFile:`,
  `+ dataWithContentsOfFile:options:error:`, `- writeToFile:atomically:`,
  `- writeToFile:atomically:error:`. Options enum `NSDataReadingOptions`
  (`NSDataReadingMappedIfSafe`, `NSDataReadingUncached`,
  `NSDataReadingMappedAlways`).
- `NSArray(OSBase)` / `NSDictionary(OSBase)`: `+ arrayWithContentsOfFile:`,
  `+ dictionaryWithContentsOfFile:`, matching `- initWithContentsOfFile:`
  and `- writeToFile:atomically:`.
- `NSData(MulleMemoryMapping)` (`NSData+MulleMemoryMapping.h`):
  `+ dataWithContentsOfMappedFile:` / `- initWithContentsOfMappedFile:`
  (also on `NSMutableData`).
- `NSCalendarDate(NSUserDefaults)` (`Categories/NSCalendarDate+NSUserDefaults.h`):
  `+ dateWithNaturalLanguageString:locale:` / `+ dateWithNaturalLanguageString:`
  on `NSDate` for date parsing from natural-language input.
- `NSCalendarDate(_Localization)` (`src/Locale/NSCalendarDate+Localization.h`):
  localized `initWithString:calendarFormat:locale:`,
  `descriptionWithCalendarFormat:locale:`, `descriptionWithLocale:`.

### 3.14. `NSError+Posix.h` (src/Posix)

```objc
MULLE_OBJC_POSIX_FOUNDATION_GLOBAL
NSString   *NSPOSIXErrorDomain;
void   MulleObjCSetPosixErrorDomain( void);
```

The Windows equivalent (`src/Windows/NSErrorWindows.h`) declares
`NSWindowsErrorDomain` and `MulleObjCSetWindowsErrorDomain`.

### 3.15. Platform C helpers

- `src/Posix/Functions/mulle-posix-tm.h`: `struct tm` helpers used for date
  parsing/formatting — `mulle_posix_tm_from_string_with_format`,
  `mulle_posix_tm_invalidate`, `mulle_posix_tm_is_invalid`,
  `mulle_posix_tm_augment`, `mulle_posix_tm_get_mini_tm`,
  `mulle_posix_tm_init_with_mini_tm`, `mulle_posix_tm_init_with_time`,
  `mulle_posix_tm_get_time`, `mulle_posix_tm_init_with_interval1970`.
- `src/BSD/mulle-bsd-tm.h`: BSD variants of the same helpers (plus
  `mulle_bsd_tm_from_string_with_format`) that forward to the Posix ones.
- `src/Windows/Functions/mulle-windows-tm.h`: Windows variants
  (`mulle_windows_tm_invalidate`, `mulle_windows_tm_is_invalid`,
  `mulle_windows_tm_get_mini_tm`, `mulle_windows_tm_init_with_mini_tm`,
  `mulle_windows_tm_init_with_time`, `mulle_windows_tm_get_time`,
  `mulle_windows_tm_init_with_interval1970`).
- `NSLocale+Posix.h` / `NSLocale+Posix-Private.h`:
  `+ systemLocalePath` and internal `_localeInfoForKey:`.
- `_NSPosixDateFormatter` / `_NSWindowsDateFormatter`: `NSDateFormatter`
  subclasses implementing `- stringFromDate:`, `- dateFromString:`, and
  `- getObjectValue:forString:range:error:` over `strftime`/`xlocale`.

## 4. Performance Characteristics

- **File reading**: `- contentsAtPath:` and `- readDataToEndOfFile` are O(n)
  in file size; `NSData(MulleMemoryMapping)` avoids a copy via `mmap`.
- **Directory enumeration**: O(1) per entry; `NSDirectoryEnumerator` streams
  entries rather than materializing the whole tree (contrast with
  `- directoryContentsAtPath:` which returns an array).
- **Process launching**: `NSTask` uses `vfork()` + `execve()` on Unix;
  launching is expensive, so reuse a long-lived task pattern or use the
  batch `mulleDataSystemCallWithArguments:` helpers.
- **Pipes**: `NSPipe` inherits the OS pipe buffer (typically 64 KB); do not
  produce more output than you concurrently drain, or the child blocks.
- **Thread-safety**: `NSFileManager`, `NSProcessInfo`, `NSUserDefaults`,
  `NSBundle` are declared `MulleObjCThreadSafe`. `NSRunLoop` is per-thread
  and must not be shared. A single `NSFileHandle` should only be accessed by
  one thread (the wrapped fd is a separate concern).
- **`NSTask(System)` helpers** read stdout and stderr concurrently with the
  child run, avoiding pipe-buffer deadlocks.

## 5. AI Usage Recommendations & Patterns

### Best Practices

- Use the singleton accessors: `[NSFileManager defaultManager]`,
  `[NSProcessInfo processInfo]`, `[NSUserDefaults standardUserDefaults]`,
  `[NSRunLoop currentRunLoop]`, `[NSBundle mainBundle]`.
- For batch/move/copy/delete/link operations with a delegate, create a
  dedicated `NSFileManager` instance instead of the shared default manager.
- Prefer the `error:`-returning `Future` variants
  (`moveItemAtPath:toPath:error:`, `createDirectoryAtPath:
   withIntermediateDirectories:attributes:error:`) when you need failure
  details; check the returned `BOOL` before proceeding.
- Use `NSTask(System)` helpers (`mulleDataSystemCallWithArguments:...`,
  `mulleStringSystemCallWithCommandString:`) for simple subprocess capture;
  they drain pipes internally. Check `NSTaskExceptionKey` in the result
  dictionary for failures.
- Always `- waitUntilExit` (or pump the run loop) before reading
  `terminationStatus`, to avoid zombie processes.
- Release resources: `-[NSFileHandle closeFile]` when done; `NSFileHandle` is
  not auto-closed. Use `@autoreleasepool` blocks in long-running loops.
- For UTF-8/native C strings use `[string cString]`/`cStringLength`; for paths
  use `fileSystemRepresentation`.

### Common Pitfalls

- Reading a pipe to completion before draining will deadlock when the child
  fills the pipe buffer; read (or use the `System` helpers) while running.
- `NSTask` cannot be relaunched; create a fresh instance per process.
- `NSFileHandle` at EOF raises `NSFileHandleOperationException` on reads;
  check `availableData`/state bits where relevant.
- Changes made with `- mulleSetEnvironmentValue:forKey:` do not affect an
  already-launched `NSTask`.
- `NSUserDefaults` persistence location varies by platform (`.config` on
  Linux, registry on Windows); do not hard-code a path.
- `NSLog` is not available from OSBase itself (link-order issues on Windows);
  always import the umbrella header.
- On Windows use `mulleWindowsFileSystemString`/`mulleUnixFileSystemString`
  to normalize path strings before comparing with `argv`.

### Idiomatic Usage

```objc
NSFileManager   *fm;
NSError         *error;
BOOL            ok;

fm = [NSFileManager defaultManager];
error = nil;
ok = [fm createDirectoryAtPath:@"/tmp/example"
             withIntermediateDirectories:YES
                              attributes:nil
                                   error:&error];
if( ! ok)
   NSLog( @"createDirectory failed: %@", error);
```

## 6. Integration Examples

### Example 1: Write, read, and delete a file

```objc
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int   main( int argc, const char * argv[])
{
   NSFileManager   *manager;
   NSString        *path;
   NSData          *written;
   NSData          *read;

   @autoreleasepool
   {
      manager = [NSFileManager defaultManager];
      path    = [[manager currentDirectoryPath] stringByAppendingPathComponent:@"example.tmp"];

      written = [NSData dataWithBytes:"Hello" length:5];
      if( ! [written writeToFile:path atomically:NO])
         return( 1);

      read = [NSData dataWithContentsOfFile:path];
      if( ! [written isEqualToData:read])
         return( 1);

      if( ! [manager removeFileAtPath:path handler:nil])
         return( 1);
   }
   return( 0);
}
```

### Example 2: Run a subprocess and capture its output

```objc
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int   main( int argc, const char * argv[])
{
   NSTask         *task;
   NSPipe         *pipe;
   NSFileHandle   *file;
   NSData         *data;

   @autoreleasepool
   {
      task = [[NSTask new] autorelease];
      pipe = [NSPipe pipe];

      [task setLaunchPath:@"/bin/echo"];
      [task setArguments:@[ @"PASS" ]];
      [task setStandardOutput:pipe];

      [task launch];

      file = [pipe fileHandleForReading];
      data = [file readDataToEndOfFile];
      [task waitUntilExit];
      if( [data length])
         write( 1, [data bytes], (size_t) [data length]);
   }
   return( 0);
}
```

### Example 3: Batch system call (deadlock-free)

```objc
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int   main( int argc, const char * argv[])
{
   NSDictionary   *result;
   NSData         *output;

   @autoreleasepool
   {
      result = [NSTask mulleDataSystemCallWithArguments:@[ @"/bin/echo", @"SYSTEM" ]
                                        workingDirectory:nil
                                       standardInputData:nil
                                                 options:NSTaskSystemReceiveStandardOutput];
      if( [result objectForKey:NSTaskExceptionKey])
         return( 1);
      output = [result objectForKey:NSTaskStandardOutputDataKey];
      if( [output length])
         write( 1, [output bytes], (size_t) [output length]);
   }
   return( 0);
}
```

### Example 4: Enumerate a directory

```objc
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int   main( int argc, const char * argv[])
{
   NSEnumerator   *rover;
   NSArray        *contents;

   @autoreleasepool
   {
      rover    = [[NSFileManager defaultManager] enumeratorAtPath:@"."];
      contents = [[rover allObjects] sortedArrayUsingSelector:@selector( compare:)];
      NSLog( @"%@", contents);
   }
   return( 0);
}
```

### Example 5: Schedule a one-shot timer on the run loop

```objc
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

@interface Repeater : NSObject
@end

@implementation Repeater

- (void) tick:(NSTimer *) timer
{
   NSLog( @"tick");
}

@end

int   main( int argc, const char * argv[])
{
   NSRunLoop     *runLoop;
   NSDate        *date;
   Repeater      *repeater;
   NSTimer       *timer;
   NSTimeInterval now;

   @autoreleasepool
   {
      repeater = [[Repeater new] autorelease];
      runLoop  = [NSRunLoop currentRunLoop];
      timer    = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:repeater
                                                selector:@selector( tick:)
                                                userInfo:nil
                                                 repeats:NO];
      now  = [NSDate timeIntervalSinceReferenceDate];
      date = [NSDate dateWithTimeIntervalSinceReferenceDate:now + 0.2];
      [runLoop runUntilDate:date];
      [timer invalidate];
   }
   return( 0);
}
```

## 7. Dependencies

Direct `mulle-sde` dependencies (from `.mulle/etc/sourcetree/config`):

- **MulleObjC** (`mulle-objc/MulleObjC`) — the Objective-C root runtime and
  the `MulleObjCStandardFoundation`/`MulleObjCValueFoundation` classes that
  `MulleObjCOSFoundation` extends.
- **mulle-objc-list** (`mulle-objc/mulle-objc-list`) — lists mulle-objc
  runtime information inside executables (build/tooling dependency).
- Internal subprojects (compiled selectively per platform): `src/OSBase`
  (portable core), `src/Posix`, `src/BSD`, `src/FreeBSD`, `src/Darwin`,
  `src/Linux`, `src/Windows`, `src/Locale`.
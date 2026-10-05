# MulleObjCOSFoundation Library Documentation for AI
<!-- Keywords: filesystem, process, task, pipe, runloop, userdefaults, platform -->

## 1. Introduction & Purpose

MulleObjCOSFoundation is the umbrella library that gives mulle-objc programs
access to operating-system functionality through Foundation-style Objective-C
classes: filesystem management (`NSFileManager`, `NSDirectoryEnumerator`),
file-descriptor I/O (`NSFileHandle`), inter-process pipes (`NSPipe`),
subprocess execution (`NSTask`), process metadata (`NSProcessInfo`),
preferences (`NSUserDefaults`), event loops (`NSRunLoop`) and plugin/resource
loading (`NSBundle`).

It solves the problem of platform divergence by exposing one API that is
implemented differently on Unix/POSIX, Linux, BSD, Darwin and Windows. The
library itself is largely a facade: it declares its own version symbol and
re-exports the OS-specific classes provided by `MulleObjCOSBaseFoundation`
(platform-neutral) and the platform libraries (`MulleObjCPosixFoundation`,
`MulleObjCBSDFoundation`, `MulleObjCFreeBSDFoundation`,
`MulleObjCDarwinFoundation`, `MulleObjCLinuxFoundation`,
`MulleObjCWindowsFoundation`). Importing `MulleObjCOSFoundation.h` is enough to
obtain all of them.

## 2. Key Concepts & Design Philosophy

- **Platform abstraction.** One Objective-C API; the concrete implementation
  (POSIX `select`/`fork`, Windows handles/registry, etc.) is chosen by the
  platform-specific library that is linked in.
- **Singletons.** Long-lived services (`NSFileManager`, `NSProcessInfo`,
  `NSUserDefaults`) are accessed through `+defaultManager`, `+processInfo` and
  `+standardUserDefaults`, not created directly.
- **"Future" categories.** Many methods that Apple marks as optional/deprecated
  live in categories (e.g. `NSFileManager(Future)`, `NSTask(Future)`) and are
  flagged with the `MulleObjCFuture` protocol. They are available at runtime but
  must be treated as optional. Tests exercise them heavily.
- **Handler / delegate callbacks.** File operations can report progress and
  errors through `NSFileManagerHandler` and `NSFileManagerDelegate`.
- **File-descriptor based I/O.** `NSFileHandle` wraps a raw fd and implements
  the mulle-objc stream protocols (`MulleObjCInputStream`,
  `MulleObjCOutputStream`); `NSPipe` hands out a read and a write handle.
- **Thread safety.** `NSFileManager`, `NSProcessInfo`, `NSUserDefaults`,
  `NSBundle` and `NSFileHandle` are declared `MulleObjCThreadSafe`. An
  `NSRunLoop` belongs to exactly one thread and must not be shared.
- **Native C-string encoding.** `NSString(CString)` converts between the
  platform's native C string encoding and `NSString`.

## 3. Core API & Data Structures

Signatures are copied verbatim from the public headers. Methods shown under a
"Future" heading belong to a `(Future)` category (optional at runtime).

### 3.1. `NSFileManager.h`

#### `NSFileManager`
- **Purpose:** High-level filesystem manipulation and directory enumeration.
- **Lifecycle:** Obtain the shared instance with `+defaultManager`. Do not
  `-init` a new manager for ordinary use; create a private instance only when
  you attach a delegate.
- **Key property:**
  - `@property( assign) id delegate;` — receives `NSFileManagerDelegate`
    callbacks.

**Creation / singleton**
```objc
+ (NSFileManager *) defaultManager;
```

**Core operations**
```objc
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
```

**Future operations**
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

- (NSDictionary *) attributesOfItemAtPath:(NSString *) path
                                    error:(NSError **) error;
- (NSDictionary *) attributesOfFileSystemForPath:(NSString *) path
                                           error:(NSError **) error;

- (BOOL) setAttributes:(NSDictionary *) attributes
          ofItemAtPath:(NSString *) path
                 error:(NSError **) error;

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
```

**File attribute keys (globals):** `NSFileType`, `NSFileSize`,
`NSFileModificationDate`, `NSFileReferenceCount`, `NSFileDeviceIdentifier`,
`NSFileOwnerAccountName`, `NSFileGroupOwnerAccountName`, `NSFilePosixPermissions`,
`NSFileSystemNumber`, `NSFileSystemFileNumber`, `NSFileSystemFreeNodes`,
`NSFileSystemFreeSize`, `NSFileSystemNodes`, `NSFileSystemSize`,
`NSFileExtensionHidden`, `NSFileHFSCreatorCode`, `NSFileHFSTypeCode`,
`NSFileImmutable`, `NSFileAppendOnly`, `NSFileCreationDate`,
`NSFileOwnerAccountID`, `NSFileGroupOwnerAccountID`, `NSFileBusy`.

**File type values:** `NSFileTypeDirectory`, `NSFileTypePipe`,
`NSFileTypeRegular`, `NSFileTypeSymbolicLink`, `NSFileTypeSocket`,
`NSFileTypeCharacterSpecial`, `NSFileTypeBlockSpecial`, `NSFileTypeUnknown`.

#### `NSFileManagerHandler` protocol
```objc
@optional
- (void)  fileManager:(NSFileManager *) fileManager
      willProcessPath:(NSString *) path;
```

#### `NSFileManagerDelegate` protocol
All methods are `@optional`; each returns `BOOL` to allow/deny the operation:
```objc
- (BOOL) fileManager:(NSFileManager *) fileManager
shouldRemoveItemAtPath:(NSString *) path;

- (BOOL) fileManager:(NSFileManager *) fileManager
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

- (BOOL) fileManager:(NSFileManager *)fileManager
shouldProceedAfterError:(NSError *)error
   movingItemAtPath:(NSString *)srcPath
             toPath:(NSString *)dstPath;
```

### 3.2. `NSDirectoryEnumerator.h`

#### `NSDirectoryEnumerator` (subclass of `NSEnumerator`)
- **Purpose:** Recursively walk a directory tree rooted at the path given to
  `-[NSFileManager enumeratorAtPath:]`.
- **Iteration:** `-nextObject` (inherited from `NSEnumerator`) returns the next
  relative path, or `nil` when exhausted. The enumerator also conforms to
  `NSFastEnumeration`.
- **Operations:**
```objc
- (NSDictionary *) directoryAttributes;
- (NSDictionary *) fileAttributes;
- (NSUInteger) count;
- (NSUInteger) level;
- (void) skipDescendants;
- (void) skipDescendents;
```
`-level` is the recursion depth (0 = top level). `-skipDescendants` (and the
misspelled Apple-compatible `-skipDescendents`) prunes the current subtree.

### 3.3. `NSFileHandle.h`

#### `NSFileHandle` (`MulleObjCInputStream`, `MulleObjCOutputStream`, `MulleObjCThreadSafe`)
- **Purpose:** Buffered/available-data I/O on a raw file descriptor. A handle
  should be used by one thread at a time even though the class is marked
  thread-safe.
- **Creation:**
```objc
+ (instancetype) fileHandleForReadingAtPath:(NSString *) path;
+ (instancetype) fileHandleForWritingAtPath:(NSString *) path;
+ (instancetype) fileHandleForUpdatingAtPath:(NSString *) path;
+ (instancetype) fileHandleWithNullDevice;

- (instancetype) initWithFileDescriptor:(int) fd;
```
- **Reading:**
```objc
- (NSData *) availableData;
- (NSData *) readDataToEndOfFile;
- (NSData *) readDataOfLength:(NSUInteger) length;
```
- **Positioning / writing:**
```objc
- (unsigned long long) offsetInFile;
- (unsigned long long) seekToEndOfFile;
- (void) seekToFileOffset:(unsigned long long) offset;
- (void) truncateFileAtOffset:(unsigned long long) offset;

- (void) writeData:(NSData *) data;

- (NSInteger) fileDescriptor;
- (void) closeFile;
```
- **mulle additions:**
```objc
- (void) mulleWriteBytes:(void *) bytes
                  length:(NSUInteger) len;   // len == (NSUInteger) -1 -> strlen

- (void) mulleAddToStateBits:(NSUInteger) bits;
- (NSUInteger) mulleGetStateBits;
```
- **Future (subclass hooks / standard streams):**
```objc
+ (instancetype) fileHandleWithStandardInput;
+ (instancetype) fileHandleWithStandardOutput;
+ (instancetype) fileHandleWithStandardError;

- (instancetype) initWithFileDescriptor:(int) fd
                         closeOnDealloc:(BOOL) flag;
- (void) synchronizeFile;
```
- **State bits:** `NSFileHandleStateEOF`, `NSFileHandleStatePipe`,
  `NSFileHandleStateAgain`; global `NSFileHandleOperationException`.

### 3.4. `NSPipe.h`

#### `NSPipe`
- **Purpose:** A unidirectional pipe pair between processes or threads.
- **API:**
```objc
+ (instancetype) pipe;

- (NSFileHandle *) fileHandleForReading;
- (NSFileHandle *) fileHandleForWriting;

- (NSInteger) _fileDescriptorForReading;
- (NSInteger) _fileDescriptorForWriting;
```

### 3.5. `NSTask.h` and `NSTask+System.h`

#### `NSTask`
- **Purpose:** Start and control a child process (`fork`/`exec` style).
- **Creation:**
```objc
+ (NSTask *) launchedTaskWithLaunchPath:(NSString *) path
                              arguments:(NSArray *) arguments;
```
`+launchedTaskWithLaunchPath:arguments:` creates, configures and launches in one
step. To configure first, create with `[[NSTask new] autorelease]`.
- **Configuration (before launch):**
```objc
- (void) setArguments:(NSArray *) arguments;
- (void) setCurrentDirectoryPath:(NSString *) path;
- (void) setEnvironment:(NSDictionary *) environmentDictionary;
- (void) setLaunchPath:(NSString *) path;
- (void) setStandardError:(id) file;
- (void) setStandardInput:(id) file;
- (void) setStandardOutput:(id) file;
```
- **Introspection:**
```objc
- (NSInteger) processIdentifier;
- (NSInteger) terminationStatus;

- (id) standardError;
- (id) standardInput;
- (id) standardOutput;

- (NSArray *) arguments;
- (NSString *) launchPath;
- (NSString *) currentDirectoryPath;
- (NSDictionary *) environment;
```
- **Future (control):**
```objc
- (BOOL) isRunning;

- (void) interrupt;
- (void) launch;
- (BOOL) resume;
- (BOOL) suspend;
- (void) terminate;
- (void) waitUntilExit;
- (NSTaskTerminationReason) terminationReason;
```
- **Termination reason:** `NSTaskTerminationReasonExit`,
  `NSTaskTerminationReasonUncaughtSignal`.

#### `NSTask(System)` convenience calls
Return a dictionary describing the run. Keys: `NSTaskExceptionKey`,
`NSTaskTerminationStatusKey`, `NSTaskStandardOutputDataKey`,
`NSTaskStandardOutputStringKey`, `NSTaskStandardErrorDataKey`,
`NSTaskStandardErrorStringKey`. Options are a bitmask:
`NSTaskSystemSendStandardInput` (0x1), `NSTaskSystemReceiveStandardOutput`
(0x2), `NSTaskSystemReceiveStandardError` (0x4); default is all three.

```objc
+ (NSDictionary *) mulleDataSystemCallWithArguments:(NSArray *) argv
                                        environment:(NSDictionary *) environment
                                   workingDirectory:(NSString *) dir
                                  standardInputData:(NSData *) inputData
                                            options:(NSTaskSystemOptions) options;

+ (NSDictionary *) mulleDataSystemCallWithArguments:(NSArray *) argv
                                   workingDirectory:(NSString *) dir
                                  standardInputData:(NSData *) inputData
                                            options:(NSTaskSystemOptions) options;

+ (NSDictionary *) mulleDataSystemCallWithArguments:(NSArray *) argv
                                        environment:(NSDictionary *) environment
                                  standardInputData:(NSData *) data;

+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv
                                          environment:(NSDictionary *) environment
                                     workingDirectory:(NSString *) dir
                                  standardInputString:(NSString *) stdinString
                                              options:(NSTaskSystemOptions) options;

+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv
                                     workingDirectory:(NSString *) dir
                                  standardInputString:(NSString *) stdinString
                                              options:(NSTaskSystemOptions) options;

+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv
                                          environment:(NSDictionary *) environment
                                  standardInputString:(NSString *) stdinString;

+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv
                                  standardInputString:(NSString *) stdinString;

+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv
                                          environment:(NSDictionary *) environment;

+ (NSDictionary *) mulleStringSystemCallWithArguments:(NSArray *) argv;

+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s
                                         workingDirectory:(NSString *) dir
                                              environment:(NSDictionary *) environment
                                      standardInputString:(NSString *) stdinString;

+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s
                                              environment:(NSDictionary *) environment
                                      standardInputString:(NSString *) stdinString;

+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s
                                      standardInputString:(NSString *) stdinString;

+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s
                                              environment:(NSString *) environment;

+ (NSDictionary *) mulleStringSystemCallWithCommandString:(NSString *) s;
```
The `...WithCommandString:` variants split the string into arguments.

### 3.6. `NSProcessInfo.h`

#### `NSProcessInfo` (`MulleObjCSingleton`, `MulleObjCThreadSafe`)
```objc
+ (NSProcessInfo *) processInfo;
```
- **Future accessors:**
```objc
- (NSString *) hostName;

- (NSUInteger) operatingSystem;
- (NSString *) operatingSystemName;
- (NSString *) operatingSystemVersionString;

- (NSArray *) arguments;
- (NSDictionary *) environment;
- (NSString *) _executablePath;

- (NSString *) processName;
- (void) setProcessName:(NSString *) name;

- (NSString *) globallyUniqueString;
- (NSInteger) processIdentifier;

- (void) mulleSetEnvironmentValue:(NSString *) value
                           forKey:(NSString *) key;   // calls setenv
```
- **Operating system constants:** `NSWindowsNTOperatingSystem`,
  `NSWindows95OperatingSystem`, `NSSolarisOperatingSystem`,
  `NSHPUXOperatingSystem`, `NSDarwinOperatingSystem`, `NSSunOSOperatingSystem`,
  `NSOSF1OperatingSystem`, `NSLinuxOperatingSystem`, `NSBSDOperatingSystem`.

### 3.7. `NSUserDefaults.h`

#### `NSUserDefaults` (`MulleObjCSingleton`, `MulleObjCThreadSafe`)
- **Purpose:** Persisted application preferences. On Darwin a plist, on Linux
  `.config`, on Windows the registry.
- **Access:**
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
```
- **Future:** `+ (void) resetStandardUserDefaults;`
- **Conveniences:**
```objc
- (BOOL)                 boolForKey:(NSString *) key;
- (double)             doubleForKey:(NSString *) key;
- (float)               floatForKey:(NSString *) key;
- (NSArray *)           arrayForKey:(NSString *) key;
- (NSArray *)     stringArrayForKey:(NSString *) key;
- (NSData *)             dataForKey:(NSString *) key;
- (NSDictionary *) dictionaryForKey:(NSString *) key;
- (NSInteger)         integerForKey:(NSString *) key;
- (NSString *)         stringForKey:(NSString *) key;

- (void) setInteger:(NSInteger)value forKey:(NSString *) key;
- (void) setFloat:(float) value        forKey:(NSString *) key;
- (void) setDouble:(double) value      forKey:(NSString *) key;
- (void) setBool:(BOOL) value          forKey:(NSString *) key;
```
- **Domain globals:** `NSGlobalDomain`, `NSArgumentDomain`,
  `NSRegistrationDomain`.

### 3.8. `NSRunLoop.h`

#### `NSRunLoop`
- **Purpose:** Per-thread event loop, usually a wrapper around `select(2)`.
  Must not be shared across threads.
```objc
+ (NSRunLoop *) currentRunLoop;
+ (NSRunLoop *) mainRunLoop;
+ (NSRunLoop *) mulleCurrentRunLoop;   // nil when the thread is shutting down

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
`NSRunLoopMode` is `NSString *`. The default mode global is
`NSDefaultRunLoopMode`.

- **`NSFileHandle(NSRunLoop)`** — background reading notifications:
```objc
- (void) readInBackgroundAndNotify;
- (void) readInBackgroundAndNotifyForModes:(NSArray *) modes;
```
Notification names: `NSFileHandleConnectionAcceptedNotification`,
`NSFileHandleDataAvailableNotification`,
`NSFileHandleReadToEndOfFileCompletionNotification`,
`NSFileHandleReadCompletionNotification`, `NSFileHandleNotificationDataItem`,
`NSFileHandleNotificationFileHandleItem`.

- **`NSObject(NSRunLoop)`** — delayed perform:
```objc
- (void) performSelector:(SEL) aSelector
              withObject:(id) anArgument
              afterDelay:(NSTimeInterval) delay
                 inModes:(NSArray *) modes;

- (void) performSelector:(SEL) aSelector
              withObject:(id) anArgument
              afterDelay:(NSTimeInterval) delay;

+ (void) cancelPreviousPerformRequestsWithTarget:(id) aTarget
                                        selector:(SEL) aSelector
                                          object:(id) anArgument;
+ (void) cancelPreviousPerformRequestsWithTarget:(id) aTarget;
```

- **`NSTimer(NSRunLoop)`**:
```objc
+ (NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval) timeInterval
                                      target:(id) target
                                    selector:(SEL) selector
                                    userInfo:(id) userInfo
                                     repeats:(BOOL) repeats;

+ (NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval) timeInterval
                                  invocation:(NSInvocation *) invocation
                                     repeats:(BOOL) repeats;

- (void) invalidate;
```

### 3.9. `NSBundle.h`

#### `NSBundle` (`MulleObjCThreadSafe`)
- **Purpose:** Locate and load code and resources (plugins, frameworks, images).
- **Creation / lookup:**
```objc
+ (NSBundle *) mainBundle;
+ (NSArray *) allFrameworks;
+ (NSArray *) allBundles;
+ (NSBundle *) bundleWithPath:(NSString *) path;
+ (NSBundle *) bundleWithIdentifier:(NSString *) identifier;

- (instancetype) initWithPath:(NSString *) fullPath;
```
- **Properties / resources:**
```objc
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
- (NSArray *) localizations;
- (NSArray *) preferredLocalizations;
- (NSDictionary *) localizedInfoDictionary;
```
- **Future / OS-specific:**
```objc
+ (BOOL) isBundleFilesystemExtension:(NSString *) extension;   // default NO
+ (NSBundle *) bundleForClass:(Class) aClass;
- (BOOL) loadBundle;
- (BOOL) unloadBundle;
```
- **Symbol lookup (mulle addition):**
```objc
- (void *) mulleLookupSymbolUTF8String:(char *) name;
- (void *) mulleLookupSymbol:(NSString *) name;
```
- **Globals / helpers:** `NSLoadedClasses`, `NSBundleDidLoadNotification`,
  `MulleObjCBundleLocalizedStringFromTable(...)`, and the
  `NSLocalizedString*` macros.

### 3.10. Supporting Categories & Functions

**`NSString(CString)`** — platform C-string conversion:
```objc
NSStringEncoding   mulle_cstring_encoding_for_codeset( char *codeset);

+ (instancetype) stringWithCString:(char *) s;
+ (instancetype) stringWithCString:(char *) s
                            length:(NSUInteger) length;

- (instancetype) initWithCString:(char *) s
                          length:(NSUInteger) len;
- (instancetype) initWithCString:(char *) s;

- (instancetype) initWithCStringNoCopy:(char *) s
                                length:(NSUInteger) length
                          freeWhenDone:(BOOL) flag;

- (void) getCString:(char *) bytes;
- (void) getCString:(char *) bytes
          maxLength:(NSUInteger) maxLength;
- (void) getCString:(char *) bytes
          maxLength:(NSUInteger) maxLength
           encoding:(NSStringEncoding) encoding;
- (void) getCString:(char *) bytes
          maxLength:(NSUInteger) maxLength
              range:(NSRange) aRange
     remainingRange:(NSRangePointer) leftoverRange;
```
Future: `cStringLength`, `defaultCStringEncoding`, `_cStringEncoding`,
`cString`.

**`NSString(OSBase)`** — path handling:
```objc
+ (instancetype) pathWithComponents:(NSArray *) components;

- (BOOL) isAbsolutePath;
- (NSString *) lastPathComponent;
- (NSString *) pathExtension;
- (NSString *) stringByAppendingPathComponent:(NSString *) component;
- (NSString *) stringByAppendingPathExtension:(NSString *) extension;
- (NSString *) stringByDeletingLastPathComponent;
- (NSString *) stringByDeletingPathExtension;
- (NSString *) stringByExpandingTildeInPath;
- (NSString *) stringByResolvingSymlinksInPath;
- (NSString *) stringByStandardizingPath;

- (NSArray *) pathComponents;
- (NSString *) initWithPathComponents:(NSArray *) components;

- (char *) fileSystemRepresentation;
- (BOOL) getFileSystemRepresentation:(char *) buf
                           maxLength:(NSUInteger) max;

+ (instancetype) stringWithContentsOfFile:(NSString *) path;

- (NSUInteger) completePathIntoString:(NSString **) outputName
                        caseSensitive:(BOOL) flag
                     matchesIntoArray:(NSArray **) outputArray
                          filterTypes:(NSArray *) filterTypes;

- (instancetype) mulleInitWithLossyContentsOfFile:(NSString *) path;
+ (instancetype) mulleStringWithLossyContentsOfFile:(NSString *) path;
- (NSString *) mulleStringBySimplifyingPath;

- (BOOL) writeToFile:(NSString *) path atomically:(BOOL) flag;
- (BOOL) writeToFile:(NSString *) path
          atomically:(BOOL) flag
            encoding:(NSStringEncoding) encoding
               error:(NSError **) error;
```
`NSString(FileSystemString)`: `-mulleUnixFileSystemString`,
`-mulleWindowsFileSystemString`.

**`NSArray(OSBase)` / `NSDictionary(OSBase)`** — property-list file I/O:
```objc
+ (instancetype) arrayWithContentsOfFile:(NSString *) path;
- (instancetype) initWithContentsOfFile:(NSString *) path;
- (BOOL) writeToFile:(NSString *) path atomically:(BOOL) flag;

+ (instancetype) dictionaryWithContentsOfFile:(NSString *) path;
- (instancetype) initWithContentsOfFile:(NSString *) path;
- (BOOL) writeToFile:(NSString *) path atomically:(BOOL) flag;
```

**`NSData(OSBase)`** — file loading:
```objc
+ (instancetype) dataWithContentsOfFile:(NSString *) path;
+ (instancetype) dataWithContentsOfFile:(NSString *) path
                                options:(NSDataReadingOptions) options
                                  error:(NSError **) error;
```
Reading options: `NSDataReadingMappedIfSafe`, `NSDataReadingUncached`,
`NSDataReadingMappedAlways`.

**`NSData(MulleMemoryMapping)` / `NSMutableData(MulleMemoryMapping)`**:
```objc
- (instancetype) initWithContentsOfMappedFile:(NSString *) path;
+ (instancetype) dataWithContentsOfMappedFile:(NSString *) path;
```

**`NSLog.h`**:
```objc
void   NSLog( NSString *format, ...);
void   NSLogv( NSString *format, va_list args);
void   NSLogArguments( NSString *format, mulle_vararg_list args);
```

**`NSPathUtilities.h`**:
```objc
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
Domain masks: `NSUserDomainMask`, `NSLocalDomainMask`, `NSNetworkDomainMask`,
`NSSystemDomainMask`, `NSAllDomainsMask` (type `NSSearchPathDomainMask`).
Directory constants: `NSApplicationDirectory` … `NSAllLibrariesDirectory`
(type `NSSearchPathDirectory`).

**`NSPageAllocation.h`**:
```objc
void   *NSAllocateMemoryPages( NSUInteger size);
void   NSDeallocateMemoryPages( void *ptr, NSUInteger size);

NSUInteger   NSPageSize( void);
NSUInteger   NSLogPageSize( void);

static inline NSUInteger   NSRoundDownToMultipleOfPageSize(NSUInteger bytes);
static inline NSUInteger   NSRoundUpToMultipleOfPageSize( NSUInteger bytes);
```

## 4. Performance Characteristics

- **Filesystem metadata** (`fileExistsAtPath:`, attribute queries): O(1) stat
  calls per path; results depend on the underlying OS.
- **Directory enumeration:** O(1) per entry, but recursively O(n) in the number
  of entries; `-skipDescendants` prunes subtrees to avoid O(subtree) work.
- **File content I/O:** O(n) in the number of bytes; `availableData` returns
  whatever is currently buffered and may block less than
  `readDataToEndOfFile`.
- **`NSTask` launch:** dominated by `fork`/`exec`/`CreateProcess`; subprocess
  startup is expensive relative to in-process calls. The
  `mulle*SystemCall*` helpers add dictionary construction and full output
  buffering (O(n) memory).
- **Pipes:** efficient IPC with a fixed OS buffer (typically 64 KiB); writing
  more than the buffer without a concurrent reader can deadlock.
- **`NSUserDefaults`:** in-memory dictionary lookups are O(1); `-synchronize`
  does file/registry I/O and is O(size of domain).
- **Thread safety:** `NSFileManager`, `NSProcessInfo`, `NSUserDefaults`,
  `NSBundle`, `NSFileHandle` are `MulleObjCThreadSafe`. `NSRunLoop` is
  per-thread and not shareable. Use a private `NSFileManager` when a delegate
  is set.

## 5. AI Usage Recommendations & Patterns

**Best practices**
- Import only `#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>`; it
  re-exports all OS classes.
- Use singletons: `+[NSFileManager defaultManager]`,
  `+[NSProcessInfo processInfo]`, `+[NSUserDefaults standardUserDefaults]`.
- Check `BOOL` results and pass an `NSError **` to the `...error:` variants for
  diagnostics.
- Prefer `+launchedTaskWithLaunchPath:arguments:` for one-shot subprocesses and
  the `mulle*SystemCall*` helpers when you just need stdout/stderr as data.
- Call `-waitUntilExit` (or poll `-isRunning`) before reading
  `-terminationStatus`, to avoid zombies.
- Drain a subprocess pipe while it runs; do not wait for exit before reading,
  or the pipe buffer may deadlock.
- Call `-closeFile` on `NSFileHandle` instances you opened.
- Use `NSFileHandle fileHandleWithNullDevice` as a safe discard sink.
- Call `-synchronize` on `NSUserDefaults` when persistence is required.

**Common pitfalls**
- Do not assume all `NSFileManager`/`NSTask` methods are always implemented:
  many live in `(Future)` categories. Check for the selector or handle a
  `nil`/`NO` result gracefully.
- `NSDirectoryEnumerator` paths are **relative** to the enumeration root, not
  absolute.
- `-fileAttributes` / `-directoryAttributes` refer to the enumerator's current
  position; call them after `-nextObject`.
- Do not reuse an `NSTask` that has already terminated; create a new one.
- `-setEnvironment:` replaces the child environment; use the
  `environment:`-taking `mulle*SystemCall*` methods to *add* to it.
- `-mulleSetEnvironmentValue:forKey:` mutates the process environment via
  `setenv` and the cached dictionary.
- No dot-syntax in mulle-objc code; use explicit message sends.

**Idiomatic usage**
```objc
NSFileManager   *fileManager;
NSTask          *task;
NSPipe          *pipe;
NSData          *output;

fileManager = [NSFileManager defaultManager];
[fileManager removeItemAtPath:@"build" error:NULL];

task = [NSTask launchedTaskWithLaunchPath:@"/bin/echo"
                                arguments:@[ @"hello" ]];
pipe = [NSPipe pipe];
[task setStandardOutput:pipe];
[task waitUntilExit];
output = [[pipe fileHandleForReading] readDataToEndOfFile];
```

## 6. Integration Examples

### Example 1: Run a Subprocess and Capture stdout

```objc
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int   main( int argc, const char * argv[])
{
   NSTask        *task;
   NSPipe        *pipe;
   NSFileHandle  *handle;
   NSData        *data;

   task = [[NSTask new] autorelease];
   pipe = [NSPipe pipe];

   [task setLaunchPath:@"/bin/echo"];
   [task setArguments:@[ @"hello", @"world" ]];
   [task setStandardOutput:pipe];

   [task launch];

   handle = [pipe fileHandleForReading];
   data   = [handle readDataToEndOfFile];

   [task waitUntilExit];

   mulle_printf( "%.*s", (int) [data length], (char *) [data bytes]);
   return( 0);
}
```

### Example 2: Enumerate a Directory Tree

```objc
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int   main( int argc, const char * argv[])
{
   NSFileManager           *fileManager;
   NSDirectoryEnumerator   *enumerator;
   NSString                *path;
   NSDictionary            *attributes;
   id                      object;

   fileManager = [NSFileManager defaultManager];
   enumerator  = [fileManager enumeratorAtPath:@"."];

   while( (object = [enumerator nextObject]))
   {
      path       = object;
      attributes = [enumerator fileAttributes];

      mulle_printf( "%*s%s\n",
                    (int) ([enumerator level] * 2), "",
                    [path UTF8String]);
      if( [[attributes objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory])
         continue;
   }

   return( 0);
}
```

### Example 3: Write and Read a File with NSFileHandle

```objc
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int   main( int argc, const char * argv[])
{
   NSFileManager   *fileManager;
   NSFileHandle    *handle;
   NSData          *data;

   fileManager = [NSFileManager defaultManager];

   [fileManager removeItemAtPath:@"example.txt" error:NULL];
   [fileManager createFileAtPath:@"example.txt"
                        contents:[NSData data]
                      attributes:nil];

   handle = [NSFileHandle fileHandleForWritingAtPath:@"example.txt"];
   [handle mulleWriteBytes:(void *) "payload"
                    length:(NSUInteger) -1];
   [handle synchronizeFile];
   [handle closeFile];

   handle = [NSFileHandle fileHandleForReadingAtPath:@"example.txt"];
   data   = [handle readDataToEndOfFile];
   [handle closeFile];

   mulle_printf( "read: %.*s\n", (int) [data length], (char *) [data bytes]);
   [fileManager removeItemAtPath:@"example.txt" error:NULL];
   return( 0);
}
```

### Example 4: Persist Preferences with NSUserDefaults

```objc
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int   main( int argc, const char * argv[])
{
   NSUserDefaults   *defaults;
   NSString         *name;
   NSInteger        score;

   defaults = [NSUserDefaults standardUserDefaults];

   [defaults setObject:@"MyApplication" forKey:@"AppName"];
   [defaults setInteger:100 forKey:@"Score"];
   [defaults synchronize];

   name  = [defaults stringForKey:@"AppName"];
   score = [defaults integerForKey:@"Score"];

   mulle_printf( "app=%s score=%ld\n",
                 [name UTF8String], (long) score);
   return( 0);
}
```

### Example 5: One-Shot System Call Convenience

```objc
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int   main( int argc, const char * argv[])
{
   NSDictionary   *result;
   NSString       *output;
   NSInteger      status;

   result = [NSTask mulleStringSystemCallWithArguments:@[ @"/bin/echo", @"hi" ]
                                             environment:nil
                                        workingDirectory:nil
                                     standardInputString:nil
                                                 options:NSTaskSystemOptionsDefault];

   output = [result objectForKey:NSTaskStandardOutputStringKey];
   status = [[result objectForKey:NSTaskTerminationStatusKey] integerValue];

   mulle_printf( "status=%ld output=%s\n",
                 (long) status, [output UTF8String]);
   return( 0);
}
```

### Example 6: Process Information

```objc
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int   main( int argc, const char * argv[])
{
   NSProcessInfo   *processInfo;
   NSDictionary    *environment;
   NSString        *path;

   processInfo = [NSProcessInfo processInfo];
   environment = [processInfo environment];
   path        = [environment objectForKey:@"PATH"];

   mulle_printf( "name=%s pid=%ld os=%s\n",
                 [[processInfo processName] UTF8String],
                 (long) [processInfo processIdentifier],
                 [[processInfo operatingSystemName] UTF8String]);
   mulle_printf( "PATH=%s\n", [path UTF8String]);
   return( 0);
}
```

## 7. Dependencies

Direct `mulle-sde` dependencies (from `.mulle/etc/sourcetree/config`):

- `MulleObjCOSBaseFoundation` — platform-neutral OS classes re-exported here.
- `MulleObjCPosixFoundation` — POSIX implementation (non-Windows).
- `MulleObjCBSDFoundation` — BSD specifics.
- `MulleObjCFreeBSDFoundation` — FreeBSD specifics.
- `MulleObjCDarwinFoundation` — Darwin/macOS specifics.
- `MulleObjCLinuxFoundation` — Linux/Android specifics.
- `MulleObjCWindowsFoundation` — Windows specifics.
- `mulle-objc-tools` — build-time tooling (`mulle-objc-list`, etc.).

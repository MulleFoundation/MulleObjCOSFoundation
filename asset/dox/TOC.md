# MulleObjCOSFoundation Library Documentation for AI
<!-- Keywords: filesystem, os-integration -->

## 1. Introduction & Purpose

MulleObjCOSFoundation provides platform-dependent Objective-C classes for operating system interaction including file I/O (NSFileManager), process management (NSTask), inter-process communication (NSPipe), environment access (NSProcessInfo), filesystem enumeration (NSDirectoryEnumerator), plugin loading (NSBundle), and event loop management (NSRunLoop). Abstracts platform differences (Unix, Linux, BSD, Darwin, Windows) behind unified Objective-C interfaces.

## 2. Key Concepts & Design Philosophy

- **Platform Abstraction**: Hides OS-specific details behind common API
- **Singleton Pattern**: Core services (NSFileManager, NSProcessInfo) use singletons
- **Delegate Pattern**: File operations support delegates for callbacks
- **Error Handling**: NSError integration for detailed error reporting
- **Thread-Safety**: Core components marked thread-safe where applicable
- **Native Encoding**: NSString categories handle platform-specific C string encodings

## 3. Core API & Data Structures

### NSFileManager - Filesystem Operations

#### Singleton Access

- `+ defaultManager` → `instancetype`: Get shared file manager instance

#### Properties

- `delegate` (id): Delegate receiving file operation callbacks

#### File Operations

- `- createFileAtPath:(NSString *)path contents:(NSData *)contents attributes:(NSDictionary *)attrs` → `BOOL`: Create file with data
- `- removeFileAtPath:(NSString *)path handler:(id)handler` → `BOOL`: Delete file
- `- contentsAtPath:(NSString *)path` → `NSData *`: Read file contents
- `- contentsEqualAtPath:(NSString *)path1 andPath:(NSString *)path2` → `BOOL`: Compare files

#### Directory Operations

- `- createDirectoryAtPath:(NSString *)path attributes:(NSDictionary *)attrs` → `BOOL`: Create directory
- `- createSymbolicLinkAtPath:(NSString *)path pathContent:(NSString *)target` → `BOOL`: Create symlink
- `- enumeratorAtPath:(NSString *)path` → `NSDirectoryEnumerator *`: Iterate directory contents

#### Delegate Protocol

```objc
@protocol NSFileManagerDelegate
- (BOOL)fileManager:(NSFileManager *)fm shouldRemoveItemAtPath:(NSString *)path;
- (BOOL)fileManager:(NSFileManager *)fm shouldMoveItemAtPath:(NSString *)src toPath:(NSString *)dst;
- (BOOL)fileManager:(NSFileManager *)fm shouldCopyItemAtPath:(NSString *)src toPath:(NSString *)dst;
- (BOOL)fileManager:(NSFileManager *)fm shouldLinkItemAtPath:(NSString *)src toPath:(NSString *)dst;
- (BOOL)fileManager:(NSFileManager *)fm shouldProceedAfterError:(NSError *)err removingItemAtPath:(NSString *)path;
@end
```

### NSDirectoryEnumerator - Directory Traversal

#### Enumeration

- `- nextObject` → `NSString *`: Next file/directory path (nil when exhausted)
- `- fileAttributes` → `NSDictionary *`: Attributes of current file
- `- skipDescendents` → `void`: Skip descending into current directory

### NSFileHandle - Low-Level File I/O

#### Opening Files

- `+ fileHandleForReadingAtPath:(NSString *)path` → `instancetype`: Open for reading
- `+ fileHandleForWritingAtPath:(NSString *)path` → `instancetype`: Open for writing
- `+ fileHandleForUpdatingAtPath:(NSString *)path` → `instancetype`: Open for read/write

#### Reading

- `- readDataToEndOfFile` → `NSData *`: Read remaining file
- `- readDataOfLength:(NSUInteger)length` → `NSData *`: Read specific bytes
- `- availableData` → `NSData *`: Read available data without blocking

#### Writing

- `- writeData:(NSData *)data` → `void`: Write data to file
- `- seekToFileOffset:(unsigned long long)offset` → `void`: Seek to position
- `- seekToEndOfFile` → `unsigned long long`: Seek to end, return position

#### Control

- `- closeFile` → `void`: Close file handle
- `- synchronizeFile` → `void`: Flush data to disk

### NSTask - Process Management

#### Creation

- `+ launchedTaskWithLaunchPath:(NSString *)path arguments:(NSArray *)args` → `instancetype`: Create and start process
- `- init` → `instancetype`: Create unstarted process

#### Configuration (before launch)

- `launchPath` (NSString *): Path to executable
- `arguments` (NSArray *): Array of argument strings
- `currentDirectoryPath` (NSString *): Working directory
- `environment` (NSDictionary *): Environment variables

#### I/O

- `standardInput` (NSPipe *): Pipe for stdin
- `standardOutput` (NSPipe *): Pipe for stdout
- `standardError` (NSPipe *): Pipe for stderr

#### Control

- `- launch` → `void`: Start the process
- `- terminate` → `void`: Terminate process
- `- waitUntilExit` → `void`: Block until process exits

#### Status

- `- isRunning` → `BOOL`: Check if still running
- `terminationStatus` (int): Exit code

### NSPipe - Inter-Process Communication

#### Creation

- `+ pipe` → `instancetype`: Create pipe pair

#### Endpoints

- `fileHandleForReading` (NSFileHandle *): Reading end
- `fileHandleForWriting` (NSFileHandle *): Writing end

### NSProcessInfo - Process Metadata

#### Singleton

- `+ processInfo` → `instancetype`: Get process information

#### Environment Access

- `environment` (NSDictionary *): Environment variables
- `arguments` (NSArray *): Command-line arguments
- `processIdentifier` (int): PID
- `processName` (NSString *): Process name
- `hostName` (NSString *): Computer hostname
- `userName` (NSString *): Current user name

### NSUserDefaults - Preferences Storage

#### Singleton

- `+ standardUserDefaults` → `instancetype`: Get standard defaults

#### Access

- `- objectForKey:(NSString *)key` → `id`: Retrieve value
- `- setObject:(id)value forKey:(NSString *)key` → `void`: Store value
- `- removeObjectForKey:(NSString *)key` → `void`: Delete value
- `- synchronize` → `BOOL`: Write to disk

#### Type-Specific Access

- `- stringForKey:(NSString *)key` → `NSString *`
- `- integerForKey:(NSString *)key` → `NSInteger`
- `- doubleForKey:(NSString *)key` → `double`
- `- boolForKey:(NSString *)key` → `BOOL`
- `- arrayForKey:(NSString *)key` → `NSArray *`
- `- dictionaryForKey:(NSString *)key` → `NSDictionary *`

### NSRunLoop - Event Processing

#### Access

- `+ currentRunLoop` → `instancetype`: Get current thread's run loop
- `+ mainRunLoop` → `instancetype`: Get main thread run loop

#### Event Loop Control

- `- run` → `void`: Run indefinitely
- `- runUntilDate:(NSDate *)date` → `void`: Run until timeout
- `- runMode:(NSString *)mode beforeDate:(NSDate *)date` → `BOOL`: Run in mode

#### File Handle Monitoring

- `- addFileHandle:(NSFileHandle *)fh forMode:(NSString *)mode` → `void`: Monitor file I/O

### NSBundle - Plugin & Resource Loading

#### Access

- `+ mainBundle` → `instancetype`: Main application bundle
- `+ bundleWithPath:(NSString *)path` → `instancetype`: Load bundle from path
- `- bundlePath` → `NSString *`: Get bundle directory path

#### Resource Loading

- `- resourcePath` → `NSString *`: Resources directory
- `- executablePath` → `NSString *`: Executable file path

### NSLog & Functions

#### Logging

- `NSLog(format, ...)`: Print timestamped log message to stderr

#### Path Utilities

- `NSHomeDirectory()` → `NSString *`: User home directory
- `NSTemporaryDirectory()` → `NSString *`: Temporary directory
- `NSUserName()` → `NSString *`: Current user name
- `NSFullUserName()` → `NSString *`: Full user name

## 4. Performance Characteristics

- **File I/O**: O(n) for file operations (n = file size)
- **Directory Enumeration**: O(1) per entry
- **Process Launching**: Significant startup cost (fork/exec)
- **Pipes**: Efficient IPC; limited buffer (typically 64KB)
- **Filesystem**: Performance depends on underlying OS and storage
- **Thread-Safety**: Core components thread-safe; NSFileHandle not thread-safe per instance

## 5. AI Usage Recommendations & Patterns

### Best Practices

- **Use NSFileManager**: For high-level file operations
- **Check Errors**: File operations return BOOL; check for failures
- **Delegate Handling**: Set delegate for batch operations to handle errors
- **Process Cleanup**: Call waitUntilExit() or check isRunning before process exit
- **Pipe Buffering**: Read output from pipes during process execution to avoid deadlock
- **Close Resources**: Always close NSFileHandle when done

### Common Pitfalls

- **Pipe Deadlock**: If process writes lots to stdout, buffer fills and deadlock occurs; read continuously
- **Process Zombies**: Not waiting for process leaves zombie; call waitUntilExit()
- **File Handle Leaks**: NSFileHandle not auto-closed; must closeFile()
- **NSTask Reuse**: Cannot relaunch same NSTask; create new instance
- **Platform Differences**: Some APIs vary by OS (Windows limitations, etc.)
- **Environment Variables**: Changes to process environment don't affect existing NSTask

### Idiomatic Usage

```objc
// Pattern 1: File I/O with error checking
NSFileManager *fm = [NSFileManager defaultManager];
NSError *error = nil;
NSData *contents = [NSFileContents contentsAtPath:@"/tmp/file.txt"];

// Pattern 2: Running subprocess and capturing output
NSTask *task = [NSTask new];
task.launchPath = @"/bin/echo";
task.arguments = @[@"Hello"];
NSPipe *pipe = [NSPipe pipe];
task.standardOutput = pipe;
[task launch];
NSData *output = [[pipe fileHandleForReading] readDataToEndOfFile];
[task waitUntilExit];

// Pattern 3: Delegate-based file operations
fm.delegate = self;
[fm removeFileAtPath:@"/tmp/file"];

// Pattern 4: Enumerating directory
NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:@"/tmp"];
NSString *file;
while ((file = [enumerator nextObject])) {
    NSLog(@"File: %@", file);
}
```

## 6. Integration Examples

### Example 1: Read File Contents

```objc
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int main() {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSData *data = [fm contentsAtPath:@"/tmp/test.txt"];
    
    if (data) {
        NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Content: %@", content);
        [content release];
    } else {
        NSLog(@"File not found or unreadable");
    }
    
    return 0;
}
```

### Example 2: Create and Write File

```objc
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int main() {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *content = @"Hello, World!";
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    BOOL success = [fm createFileAtPath:@"/tmp/output.txt" 
                               contents:data 
                             attributes:nil];
    
    if (success) {
        NSLog(@"File created successfully");
    } else {
        NSLog(@"Failed to create file");
    }
    
    return 0;
}
```

### Example 3: Run External Command

```objc
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int main() {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/ls";
    task.arguments = @[@"-la", @"/tmp"];
    
    NSPipe *pipe = [NSPipe pipe];
    task.standardOutput = pipe;
    
    [task launch];
    
    NSData *output = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *result = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
    NSLog(@"Output:\n%@", result);
    
    [task waitUntilExit];
    
    [result release];
    [task release];
    
    return 0;
}
```

### Example 4: Enumerate Directory

```objc
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int main() {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:@"/tmp"];
    
    NSString *file;
    while ((file = [enumerator nextObject])) {
        NSLog(@"File: %@", file);
    }
    
    return 0;
}
```

### Example 5: Access Environment and Process Info

```objc
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int main() {
    NSProcessInfo *pi = [NSProcessInfo processInfo];
    
    NSLog(@"Process name: %@", pi.processName);
    NSLog(@"Process ID: %d", pi.processIdentifier);
    NSLog(@"User: %@", pi.userName);
    NSLog(@"Hostname: %@", pi.hostName);
    
    NSDictionary *env = pi.environment;
    NSString *path = [env objectForKey:@"PATH"];
    NSLog(@"PATH: %@", path);
    
    return 0;
}
```

### Example 6: User Defaults (Preferences)

```objc
#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>

int main() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Store value
    [defaults setObject:@"MyApplication" forKey:@"AppName"];
    [defaults setInteger:100 forKey:@"Score"];
    [defaults synchronize];
    
    // Retrieve value
    NSString *appName = [defaults stringForKey:@"AppName"];
    NSInteger score = [defaults integerForKey:@"Score"];
    
    NSLog(@"App: %@, Score: %ld", appName, score);
    
    return 0;
}
```

## 7. Dependencies

- MulleObjCValueFoundation (NSString, NSData, NSDictionary)
- MulleObjCContainerFoundation (NSArray)
- MulleObjCTimeFoundation (NSDate, NSTimeInterval)
- MulleFoundationBase
- Platform C libraries (POSIX, Windows API, etc.)

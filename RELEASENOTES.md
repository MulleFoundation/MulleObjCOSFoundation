## 0.27.0


* comprehensive verbatim signatures for NSFileManager, NSFileHandle, NSTask, NSPipe, NSProcessInfo, NSUserDefaults, NSRunLoop and NSBundle
* document (Future) category methods as runtime-optional so callers guard against unimplemented selectors
* add NSString(CString)/NSString(OSBase), NSArray/NSDictionary plist I/O and NSData memory-mapping categories plus NSPathUtilities and NSPageAllocation helpers
* clarify singleton access, thread-safety guarantees and common pitfalls such as relative enumerator paths and pipe deadlock
* update the dependency list to the split MulleObjC* platform foundation libraries




* comprehensive NSLocale test suite covering canonical identifiers, components
  and ISO code derivation
* regression tests for locale equality/hashing, display names, collation,
  delimiters, language direction and thread-safe derived key caching
* tests for C string encoding, lossy conversion and file system
  representation round-tripping
* tests for NSDateFormatter timezone parsing and NSCalendarDate month accessor











* NSTask, NSFileManager and NSBundle tests formerly restricted to Windows now run on all platforms, guarded by per-platform skip markers
* added NSProcessInfo tests for executable path resolution and `setProcessName:` behavior, including Darwin-specific expectations
* generated docs: new API summary table of contents (asset/dox/api/toc/index.md)


### 0.26.1


feature: add NSLocale( Posix) category for platform-specific locale extensions

* new NSLocale( Posix) category declaration
feature: add NSLocale( Posix) category for platform-specific locale extensions

* new NSLocale( Posix) category declaration

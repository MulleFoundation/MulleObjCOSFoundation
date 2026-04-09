## 0.26.0








  NSCalendarDate, `_NSWindowsDateFormatter`






feature: add Windows platform implementations and refresh OS-specific Foundation code

* Add Windows implementations for core Foundation classes (NSFileManager, NSTask, NSRunLoop, NSString/NSDate helpers) with UTF-16 filesystem support and Unix↔Windows path conversion.
* Refresh and align POSIX/BSD/Darwin/FreeBSD/Linux implementations and expand tests (NSDateFormatter, NSFileManager, NSTask) to ensure consistent cross-platform behavior.

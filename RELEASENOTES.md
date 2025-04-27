### 0.24.1


* better searchpath code for linux

## 0.24.0

* made NSFileHandle threadsafe, which needed -closeFile to explicitly call -finalize now


## 0.23.0

feat: enhance thread safety and system integration

* Add Thread Affine Objects (TAO) support
  - Enable TAO for debug builds via `OBJC_TAO_DEBUG_ENABLED` option
  - Add TAO compiler flag (-fobjc-tao) when enabled
  - Improve thread safety in object access patterns

* Enhance NSTask system integration
  - Add thread safety with mulleGainAccess/mulleRelinquishAccess
  - Replace mulleStartUndetached with mulleStart for better thread control
  - Add new convenience methods for environment modification
  - Support both single and double quotes in command parsing
  - Add workingDirectory support to string-based system calls
  - Improve debug tracing with `trace_launch` function

* Optimize BSD date handling
  - Remove unused `mulle_mini_tm_init_with_time` function
  - Remove redundant temporary variables
  - Improve time conversion efficiency

* Improve build system resilience
  - Change `FATAL_ERROR` to `SEND_ERROR` for better build continuity
  - Fix `WANTED_WARNINGS` vs `UNWANTED_WARNINGS` logic
  - Add better error reporting with detailed messages
  - Support version 0.23.0 improvements

* Add debugging improvements
  - Add conditional compilation for debug features
  - Enhance error reporting with better context
  - Add trace functionality for command execution


## 0.22.0

* NSTask system methods now have variants where you can *modify* (not set) the tasks environment


### 0.21.4

* fix for cosmopolitan

### 0.21.3

* fix NSDirectoryEnumerator, which was seemingly abandoned mid-write

### 0.21.2

* greatly improve NSTask launch, so it works with vfork and fork
* rewrote the "system" functionality completely
* improved NSFileHandle
* -[NSData initWithContentsOfFile:] with an empty file now returns an empty NSData and not nil

### 0.21.1

* Various small improvements

## 0.21.0

* change GLOBAL for Windows
* move NSTimer and NSDate related code to MulleObjCTimeFoundation


## 0.20.0

* leak fix for NSBundle
* fixes in the POSIX NSDateFormatter
* improved `+availableLocaleIdentifiers`

## 0.19.0

* some refinements for NSFileHandle


## 0.18.0

* improved NSFileManager a bit
* fix NSFileHandle closing


### 0.17.1

* new mulle-sde project structure

## 0.17.0

* renamed Base to OSBase
* cut dependency on MulleObjCInetFoundation, move some code to new MulleObjCOSInetFoundation
* NSString's ``_stringBySimplifyingPath`` is now `mulleStringBySimplifyingPath`
* NSTimeZone`s ``_GMTTimeZone`` is now `mulleGMTTimeZone`
* adapted to changes in MulleObjC
* add mulleWriteBytes:length: method to NSFileHandle
* move NSConditionLock to MulleFoundation
* fix NSCondition a little bit
* fix timeIntervalSince1970 miscalculation in NSDate
* add pre-cursory Windows subproject
* add memory mapped NSData (read only) based on mulle-mmap


## 0.16.0

* fix infinite recursion on Darwin
* improved NSRunLoop can now do performMessages and NSTimer
* multiple bugfixes with proper handling of nil parameters
* added NSURLFileScheme to NSURL
* improved NSBundle
* added MulleDateNow() function and based NSDate on gettimeofday instead of time


### 0.15.1

* fix stringByResolvingSymlinksInPath and stringByStandardizingPath
* fix leak with GMT Timezone

## 0.15.0

* fix unavoidable setProcessName leak tripping up tests
* rename many `_methods` to mulleMethods, to distinguish between private and just not compatible
* added some of the uncherished error:(NSError **) error method variations for compatibility
* improved `mulleStringBySimplifyingPath`
* added some more "well known" directory names, such as NSTrashDirectonary
* improved NSBundle, NSFileHandle, NSFileManager, NSProcessInfo, NSError


### 0.14.1

* modernized to new mulle-test

## 0.14.0

* modernized project structure and tests


### 0.13.2

* modernize mulle-sde cmake, fix a test for linux

### 0.13.1

* fix for mingw

## 0.13.0

* migration to mulle-sde completed


### 0.12.1

* Various small improvements

### 0.9.1

* modernize CMakeLists.txt and CMakeDependencies.txt
* separate OS into constituent libraries, so each library has one loader only
* make it a cmake "C" project

# 0.2.0

* start versioning

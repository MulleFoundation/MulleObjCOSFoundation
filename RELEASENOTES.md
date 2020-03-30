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

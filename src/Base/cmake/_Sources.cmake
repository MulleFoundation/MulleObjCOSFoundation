# cmake/_Sources.cmake is generated by `mulle-sde`. Edits will be lost.
#
if( MULLE_TRACE_INCLUDE)
   MESSAGE( STATUS "# Include \"${CMAKE_CURRENT_LIST_FILE}\"" )
endif()

set( SOURCES
Categories/NSArchiver+OSBase.m
Categories/NSArray+OSBase-Private.m
Categories/NSArray+OSBase.m
Categories/NSCalendarDate+NSUserDefaults.m
Categories/NSData+OSBase.m
Categories/NSDictionary+OSBase-Private.m
Categories/NSDictionary+OSBase.m
Categories/NSHost+OSBase.m
Categories/NSString+CString.m
Categories/NSString+OSBase.m
Categories/NSTask+System.m
Categories/NSURL+OSBase.m
Functions/NSPageAllocation.m
Functions/NSPathUtilities.m
NSBundle.m
NSConditionLock.m
NSDirectoryEnumerator.m
NSFileHandle+NSRunLoop.m
NSFileHandle.m
NSFileManager.m
NSPipe.m
NSProcessInfo.m
NSRunLoop.m
NSTask.m
NSUserDefaults.m
)

set( STAGE2_SOURCES
MulleObjCLoader+MulleObjCOSBaseFoundation.m
)

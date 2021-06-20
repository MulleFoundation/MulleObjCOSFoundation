#
# This file will be included by cmake/share/sources.cmake
#
# cmake/reflect/_Sources.cmake is generated by `mulle-sde reflect`.
# Edits will be lost.
#
if( MULLE_TRACE_INCLUDE)
   MESSAGE( STATUS "# Include \"${CMAKE_CURRENT_LIST_FILE}\"" )
endif()

#
# contents selected with patternfile ??-source--sources
#
set( SOURCES
_MulleGMTTimeZone+Linux.m
NSBundle+Linux.m
NSCalendarDate+Linux.m
NSDateFormatter+Linux.m
NSFileManager+Linux.m
NSLocale+Linux.m
NSPathUtilities+Linux.m
NSProcessInfo+Linux.m
NSString+Linux.m
NSTask+Linux.m
NSTimeZone+Linux.m
)

#
# contents selected with patternfile ??-source--stage2-sources
#
set( STAGE2_SOURCES
MulleObjCLoader+MulleObjCLinuxFoundation.m
)

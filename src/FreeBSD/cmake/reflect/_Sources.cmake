#
# cmake/reflect/_Sources.cmake is generated by `mulle-sde reflect`. Edits will be lost.
#
if( MULLE_TRACE_INCLUDE)
   MESSAGE( STATUS "# Include \"${CMAKE_CURRENT_LIST_FILE}\"" )
endif()

set( SOURCES
NSBundle+FreeBSD.m
NSFileManager+FreeBSD.m
NSPathUtilities+FreeBSD.m
NSProcessInfo+FreeBSD.m
NSString+FreeBSD.m
NSTask+FreeBSD.m
)

set( STAGE2_SOURCES
MulleObjCLoader+MulleObjCFreeBSDFoundation.m
)

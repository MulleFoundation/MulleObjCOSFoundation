#
# cmake/_Headers.cmake is generated by `mulle-sde`. Edits will be lost.
#
if( MULLE_TRACE_INCLUDE)
   MESSAGE( STATUS "# Include \"${CMAKE_CURRENT_LIST_FILE}\"" )
endif()

set( PRIVATE_HEADERS
import-private.h
include-private.h
)

set( PUBLIC_HEADERS
import.h
include.h
mulle_bsd_tm.h
)


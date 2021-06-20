#
# This file will be included by cmake/share/Files.cmake
#
# cmake/reflect/_Libraries.cmake is generated by
# `mulle-sourcetree-to-cmake` via `mulle-sde reflect`.
# Edits will be lost.
#
# Disable generation of this file with:
#
# mulle-sde environment set MULLE_SOURCETREE_TO_CMAKE_LIBRARIES_FILE DISABLE
#
if( MULLE_TRACE_INCLUDE)
   message( STATUS "# Include \"${CMAKE_CURRENT_LIST_FILE}\"" )
endif()

#
# Generated from sourcetree: c9b589de-edca-4be3-81a7-401e29bb43aa;MulleObjCPosixFoundation;no-build,no-cmake-inherit,no-delete,no-dependency,no-fs,no-link,no-update;
# Disable with : `mulle-sourcetree mark MulleObjCPosixFoundation `
# Disable for this platform: `mulle-sourcetree mark MulleObjCPosixFoundation no-cmake-platform-linux`
#
if( NOT MULLE_OBJC_POSIX_FOUNDATION_HEADER)
   find_file( MULLE_OBJC_POSIX_FOUNDATION_HEADER NAMES MulleObjCPosixFoundation/MulleObjCPosixFoundation.h MulleObjCPosixFoundation/MulleObjCPosixFoundation.h)
   message( STATUS "MULLE_OBJC_POSIX_FOUNDATION_HEADER is ${MULLE_OBJC_POSIX_FOUNDATION_HEADER}")

   #
   # Add MULLE_OBJC_POSIX_FOUNDATION_HEADER to ALL_LOAD_HEADER_ONLY_LIBRARIES list.
   # Disable with: `mulle-sourcetree mark MulleObjCPosixFoundation no-cmake-add`
   #
   set( ALL_LOAD_HEADER_ONLY_LIBRARIES
      ${MULLE_OBJC_POSIX_FOUNDATION_HEADER}
      ${ALL_LOAD_HEADER_ONLY_LIBRARIES}
      CACHE INTERNAL "need to cache this"
   )
   if( MULLE_OBJC_POSIX_FOUNDATION_HEADER)
      # intentionally left blank
   else()
      # Disable with: `mulle-sourcetree mark MulleObjCPosixFoundation no-require`
      message( FATAL_ERROR "MULLE_OBJC_POSIX_FOUNDATION_HEADER was not found")
   endif()
endif()

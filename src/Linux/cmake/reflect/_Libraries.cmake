# This file will be regenerated by `mulle-sourcetree-to-cmake` via
# `mulle-sde reflect` and any edits will be lost.
#
# This file will be included by cmake/share/Files.cmake
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
# Disable for this platform: `mulle-sourcetree mark MulleObjCPosixFoundation no-cmake-platform-${MULLE_UNAME}`
# Disable for a sdk: `mulle-sourcetree mark MulleObjCPosixFoundation no-cmake-sdk-<name>`
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
   )
   if( MULLE_OBJC_POSIX_FOUNDATION_HEADER)
      # intentionally left blank
   else()
      # Disable with: `mulle-sourcetree mark MulleObjCPosixFoundation no-require`
      message( SEND_ERROR "MULLE_OBJC_POSIX_FOUNDATION_HEADER was not found")
   endif()
endif()

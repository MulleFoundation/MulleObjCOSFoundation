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
# Generated from sourcetree: 6c6822fe-585d-4917-ab85-0261ee3ebe86;MulleObjCOSBaseFoundation;no-build,no-delete,no-dependency,no-fs,no-link,no-update;
# Disable with : `mulle-sourcetree mark MulleObjCOSBaseFoundation `
# Disable for this platform: `mulle-sourcetree mark MulleObjCOSBaseFoundation no-cmake-platform-${MULLE_UNAME}`
# Disable for a sdk: `mulle-sourcetree mark MulleObjCOSBaseFoundation no-cmake-sdk-<name>`
#
if( NOT MULLE_OBJC_OS_BASE_FOUNDATION_HEADER)
   find_file( MULLE_OBJC_OS_BASE_FOUNDATION_HEADER NAMES MulleObjCOSBaseFoundation/MulleObjCOSBaseFoundation.h MulleObjCOSBaseFoundation/MulleObjCOSBaseFoundation.h)
   message( STATUS "MULLE_OBJC_OS_BASE_FOUNDATION_HEADER is ${MULLE_OBJC_OS_BASE_FOUNDATION_HEADER}")

   #
   # Add MULLE_OBJC_OS_BASE_FOUNDATION_HEADER to ALL_LOAD_HEADER_ONLY_LIBRARIES list.
   # Disable with: `mulle-sourcetree mark MulleObjCOSBaseFoundation no-cmake-add`
   #
   set( ALL_LOAD_HEADER_ONLY_LIBRARIES
      ${MULLE_OBJC_OS_BASE_FOUNDATION_HEADER}
      ${ALL_LOAD_HEADER_ONLY_LIBRARIES}
   )
   if( MULLE_OBJC_OS_BASE_FOUNDATION_HEADER)
      #
      # Inherit ObjC loader and link dependency info.
      # Disable with: `mulle-sourcetree mark MulleObjCOSBaseFoundation no-cmake-inherit`
      #
      get_filename_component( _TMP_MULLE_OBJC_OS_BASE_FOUNDATION_ROOT "${MULLE_OBJC_OS_BASE_FOUNDATION_HEADER}" DIRECTORY)
      get_filename_component( _TMP_MULLE_OBJC_OS_BASE_FOUNDATION_NAME "${_TMP_MULLE_OBJC_OS_BASE_FOUNDATION_ROOT}" NAME)
      get_filename_component( _TMP_MULLE_OBJC_OS_BASE_FOUNDATION_ROOT "${_TMP_MULLE_OBJC_OS_BASE_FOUNDATION_ROOT}" DIRECTORY)
      get_filename_component( _TMP_MULLE_OBJC_OS_BASE_FOUNDATION_ROOT "${_TMP_MULLE_OBJC_OS_BASE_FOUNDATION_ROOT}" DIRECTORY)
      #
      # Search for "Definitions.cmake" and "DependenciesAndLibraries.cmake" to include.
      # Disable with: `mulle-sourcetree mark MulleObjCOSBaseFoundation no-cmake-dependency`
      #
      foreach( _TMP_MULLE_OBJC_OS_BASE_FOUNDATION_NAME IN LISTS _TMP_MULLE_OBJC_OS_BASE_FOUNDATION_NAME)
         set( _TMP_MULLE_OBJC_OS_BASE_FOUNDATION_DIR "${_TMP_MULLE_OBJC_OS_BASE_FOUNDATION_ROOT}/include/${_TMP_MULLE_OBJC_OS_BASE_FOUNDATION_NAME}/cmake")
         # use explicit path to avoid "surprises"
         if( IS_DIRECTORY "${_TMP_MULLE_OBJC_OS_BASE_FOUNDATION_DIR}")
            list( INSERT CMAKE_MODULE_PATH 0 "${_TMP_MULLE_OBJC_OS_BASE_FOUNDATION_DIR}")
            #
            include( "${_TMP_MULLE_OBJC_OS_BASE_FOUNDATION_DIR}/DependenciesAndLibraries.cmake" OPTIONAL)
            #
            list( REMOVE_ITEM CMAKE_MODULE_PATH "${_TMP_MULLE_OBJC_OS_BASE_FOUNDATION_DIR}")
            #
            unset( MULLE_OBJC_OS_BASE_FOUNDATION_DEFINITIONS)
            include( "${_TMP_MULLE_OBJC_OS_BASE_FOUNDATION_DIR}/Definitions.cmake" OPTIONAL)
            list( APPEND INHERITED_DEFINITIONS ${MULLE_OBJC_OS_BASE_FOUNDATION_DEFINITIONS})
            break()
         else()
            message( STATUS "${_TMP_MULLE_OBJC_OS_BASE_FOUNDATION_DIR} not found")
         endif()
      endforeach()
      #
      # Search for "MulleObjCLoader+<name>.h" in include directory.
      # Disable with: `mulle-sourcetree mark MulleObjCOSBaseFoundation no-cmake-loader`
      #
      if( NOT NO_INHERIT_OBJC_LOADERS)
         foreach( _TMP_MULLE_OBJC_OS_BASE_FOUNDATION_NAME IN LISTS _TMP_MULLE_OBJC_OS_BASE_FOUNDATION_NAME)
            set( _TMP_MULLE_OBJC_OS_BASE_FOUNDATION_FILE "${_TMP_MULLE_OBJC_OS_BASE_FOUNDATION_ROOT}/include/${_TMP_MULLE_OBJC_OS_BASE_FOUNDATION_NAME}/MulleObjCLoader+${_TMP_MULLE_OBJC_OS_BASE_FOUNDATION_NAME}.h")
            if( EXISTS "${_TMP_MULLE_OBJC_OS_BASE_FOUNDATION_FILE}")
               list( APPEND INHERITED_OBJC_LOADERS ${_TMP_MULLE_OBJC_OS_BASE_FOUNDATION_FILE})
               break()
            endif()
         endforeach()
      endif()
   else()
      # Disable with: `mulle-sourcetree mark MulleObjCOSBaseFoundation no-require`
      message( FATAL_ERROR "MULLE_OBJC_OS_BASE_FOUNDATION_HEADER was not found")
   endif()
endif()

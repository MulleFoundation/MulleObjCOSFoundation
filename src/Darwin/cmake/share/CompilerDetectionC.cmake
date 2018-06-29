if( NOT __COMPILER_DETECTION_C_CMAKE__)
   set( __COMPILER_DETECTION_C_CMAKE__ ON)

   if( MULLE_TRACE_INCLUDE)
      message( STATUS "# Include \"${CMAKE_CURRENT_LIST_FILE}\"" )
   endif()

   #
   if( NOT MULLE_C_COMPILER_ID)
      if( ("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows") AND ( "${CMAKE_C_COMPILER_ID}" MATCHES "^(Clang|MulleClang)$") )
         set( MULLE_C_COMPILER_ID "MSVC-${CMAKE_C_COMPILER_ID}")
      else()
         set( MULLE_C_COMPILER_ID "${CMAKE_C_COMPILER_ID}")
      endif()
   endif()

   if( NOT MULLE_CXX_COMPILER_ID)
      if( ("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows") AND ( "${CMAKE_CXX_COMPILER_ID}" MATCHES "^(Clang|MulleClang)$") )
         set( MULLE_CXX_COMPILER_ID "MSVC-${CMAKE_CXX_COMPILER_ID}")
      else()
         set( MULLE_CXX_COMPILER_ID "${CMAKE_CXX_COMPILER_ID}")
      endif()
   endif()

endif()

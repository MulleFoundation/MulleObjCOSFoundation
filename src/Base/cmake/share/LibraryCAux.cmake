if( NOT __LIBRARY_C_AUX_CMAKE__)
   set( __LIBRARY_C_AUX_CMAKE__ ON)

   if( MULLE_TRACE_INCLUDE)
      message( STATUS "# Include \"${CMAKE_CURRENT_LIST_FILE}\"" )
   endif()

   include( CreateLoaderIncObjC)

   include( LibraryObjCAux OPTIONAL)

endif()
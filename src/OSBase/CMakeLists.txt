cmake_minimum_required( VERSION 3.13...99.99)

project( MulleObjCOSBaseFoundation C)


### mulle-sde environment

# add cmake module paths to search path
list( INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake/share")
list( INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake/reflect")
list( INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake")

include( Environment)

include( Files)

### Library

if( HEADERS_PHASE)
   install( FILES ${INSTALL_PUBLIC_HEADERS}  DESTINATION "include/MulleObjCOSBaseFoundation")
   install( FILES ${INSTALL_PRIVATE_HEADERS} DESTINATION "include/MulleObjCOSBaseFoundation")
   install( FILES ${INSTALL_CMAKE_INCLUDES}          DESTINATION "include/MulleObjCOSBaseFoundation/cmake")

   # short cut out
   if( NOT COMPILE_PHASE AND NOT LINK_PHASE)
      return()
   endif()
endif()

if( LINK_PHASE)
   include( Dependencies OPTIONAL)
endif()

include( Library)

if( LINK_PHASE)
   # Allow unresolved symbols on Windows (for mulle_atexit, __register_mulle_objc_universe)
   if( WIN32 OR MINGW)
      target_link_options( "${LIBRARY_LINK_TARGET}" PRIVATE "-Wl,/FORCE:UNRESOLVED")
   endif()
endif()

include( InstallLibrary)
include( FinalOutput OPTIONAL)

/*
*   This file will be regenerated by `mulle-sde reflect` and any edits will be
*   lost. Suppress generation of this file with:
*      mulle-sde environment --global \
*         set MULLE_SOURCETREE_TO_C_IMPORT_FILE DISABLE
*
*   To not generate any header files:
*      mulle-sde environment --global \
*         set MULLE_SOURCETREE_TO_C_RUN DISABLE
*/

#ifndef _MulleObjCDarwinFoundation_import_h__
#define _MulleObjCDarwinFoundation_import_h__

// How to tweak the following MulleObjCPosixFoundation #import
//    remove:             `mulle-sourcetree mark MulleObjCPosixFoundation no-header`
//    rename:             `mulle-sde dependency|library set MulleObjCPosixFoundation include whatever.h`
//    toggle #import:     `mulle-sourcetree mark MulleObjCPosixFoundation [no-]import`
//    toggle localheader: `mulle-sourcetree mark MulleObjCPosixFoundation [no-]localheader`
//    toggle public:      `mulle-sourcetree mark MulleObjCPosixFoundation [no-]public`
//    toggle optional:    `mulle-sourcetree mark MulleObjCPosixFoundation [no-]require`
//    remove for os:      `mulle-sourcetree mark MulleObjCPosixFoundation no-os-<osname>`
# if defined( __has_include) && __has_include("MulleObjCPosixFoundation.h")
#   import "MulleObjCPosixFoundation.h"   // MulleObjCPosixFoundation
# else
#   import <MulleObjCPosixFoundation/MulleObjCPosixFoundation.h>   // MulleObjCPosixFoundation
# endif

#ifdef __has_include
# if __has_include( "_MulleObjCDarwinFoundation-include.h")
#  include "_MulleObjCDarwinFoundation-include.h"
# endif
#endif


#endif

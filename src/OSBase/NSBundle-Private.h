//
//  NSBundle-Private.h
//  MulleObjCOSFoundation
//
//  Copyright (c) 2020 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
struct _MulleObjCSharedLibrary
{
   NSString   *path;
   void       *start;
   void       *end;
   void       *handle;   // usually NULL, except if NSBundle should own and close
};



@interface NSBundle( PrivateFuture) < MulleObjCFuture>

+ (NSDictionary *) _bundleDictionary;
+ (NSArray *) _allBundlesWhichAreFrameworks:(BOOL) flag;
+ (NSBundle *) _bundleForHandle:(void *) handle;

+ (NSArray *) _pathsWithExtension:(NSString *) extension
                      inDirectory:(NSString *) path;

+ (NSString *)  _OSIdentifier;
+ (NSString *) _mainBundlePathForExecutablePath:(NSString *) executablePath;
+ (NSString *) _bundlePathForExecutablePath:(NSString *) executablePath;

- (id) __mulleInitWithPath:(NSString *) fullPath
    sharedLibraryInfo:(struct _MulleObjCSharedLibrary *) libInfo;
- (id) _mulleInitWithPath:(NSString *) fullPath
    sharedLibraryInfo:(struct _MulleObjCSharedLibrary *) libInfo;

- (NSString *) _executablePath;
- (NSString *) _resourcePath;

- (BOOL) mulleContainsAddress:(void *) address;
+ (NSDictionary *) mulleRegisteredBundleInfo;

//
// Contains struct _MulleObjCSharedLibrary
// The number of contained structs can be determined by
// [data length] / sizeof( struct _MulleObjCSharedLibrary)
// the string values inside it are autoreleased. Don't retain this data
// EVER!
// possibly including main exe (dunno)
+ (NSData *) _allSharedLibraries;

- (void) willLoad;
- (void) didLoad;

@end


//
//  NSDictionary+OSBase-Private.m
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
#import "import-private.h"

#import "NSDictionary+OSBase-Private.h"

// other files in this library
#import "NSString+CString.h"

// std-c and dependencies
#include <stddef.h>


@implementation NSDictionary( OSBase_Private)

+ (instancetype) _newWithEnvironment:(char **) env
{
   NSMutableDictionary   *dictionary;
   NSString              *key;
   NSString              *value;
   char                  **p;
   char                  *s;
   char                  *c_key;
   char                  *c_value;
   size_t                c_key_len;
   size_t                c_value_len;

   dictionary = [NSMutableDictionary new];

   p = env;
   while( *p)
   {
      s       = *p++;
      c_key   = s;
      c_value = strchr( s, '=');

      if( c_value)
      {
         c_key_len = c_value - c_key;
         if( ! *++c_value)
            c_value = NULL;
         else
            c_value_len = strlen( c_value);
      }
      else
         c_key_len = strlen( c_key);

      key = [[NSString alloc] initWithCString:c_key
                                       length:c_key_len];
      if( c_value)
         value = [[NSString alloc] initWithCString:c_value
                                            length:c_value_len];
      else
         value = [@"" retain];

      [dictionary mulleSetRetainedObject:value
                            forCopiedKey:key];
   }

   return( dictionary);
}
@end

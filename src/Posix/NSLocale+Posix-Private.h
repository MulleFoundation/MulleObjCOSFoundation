//
//  NSLocale+Posix-Private.h
//  MulleObjCOSFoundation
//
//  Copyright (c) 2018 Nat! - Mulle kybernetiK.
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
#include <locale.h>


struct mulle_locale_key_info
{
   unsigned short   type;
   unsigned short   code;
};


static inline struct mulle_locale_key_info   make_mulle_locale_key_info( NSUInteger type, NSUInteger code)
{
   NSCParameterAssert( type == (NSUInteger) -1 || type <= USHRT_MAX);
   NSCParameterAssert( code <= USHRT_MAX);

   struct mulle_locale_key_info    info;

   info.type  = (unsigned short) type;
   info.code  = (unsigned short) code;
   return( info);
}


enum
{
   ERROR_INFO = -1,
   IDENTIFIER_INFO,
   LANG_INFO,
   CONV_INFO,
   QUERY_INFO
};


enum
{
   QUERY_COLLATION,
   QUERY_IDENTIFIER,
   QUERY_LANGUAGE,
   QUERY_SCRIPT,
   QUERY_VARIANT

};

enum
{
   CONV_DECIMAL_POINT,
   CONV_THOUSANDS_SEPERATOR,
   CONV_GROUPING,
   CONV_INT_CURRENCY_SYMBOL,
   CONV_CURRENCY_SYMBOL,
   CONV_MONEY_DECIMAL_POINT,
   CONV_MONEY_THOUSANDS_SEPERATOR,
   CONV_MONEY_GROUPING,
   CONV_POSITIVE_SIGN,
   CONV_NEGATIVE_SIGN,
   CONV_INT_FRACTIONAL_DIGITS,
   CONV_FRACTIONAL_DIGITS,
   CONV_POSITIVE_VALUE_CURRENCY_SYMBOL_PRECEDES,
   CONV_POSITIVE_VALUE_CURRENCY_SYMBOL_SEPARATED_BY_SPACE,
   CONV_NEGATIVE_VALUE_CURRENCY_SYMBOL_PRECEDES,
   CONV_NEGATIVE_VALUE_CURRENCY_SYMBOL_SEPARATED_BY_SPACE,
   CONV_POSITIVE_SIGN_POSITION,
   CONV_NEGATIVE_SIGN_POSITION,
   CONV_INT_POSITIVE_VALUE_CURRENCY_SYMBOL_PRECEDES,
   CONV_INT_NEGATIVE_VALUE_CURRENCY_SYMBOL_PRECEDES,
   CONV_INT_POSITIVE_VALUE_CURRENCY_SYMBOL_SEPARATED_BY_SPACE,
   CONV_INT_NEGATIVE_VALUE_CURRENCY_SYMBOL_SEPARATED_BY_SPACE,
   CONV_INT_POSITIVE_SIGN_POSITION,
   CONV_INT_NEGATIVE_SIGN_POSITION
};


struct mulle_locale_key_info   mulle_locale_map_string_key_to_local_key( NSString *key);

id    mulle_locale_lconv_value( struct lconv *conv, int code);


@interface NSLocale( Posix_PrivateFuture) < MulleObjCFuture>

- (locale_t) xlocale;

@end

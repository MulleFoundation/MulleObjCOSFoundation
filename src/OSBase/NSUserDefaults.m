//
//  NSUserDefaults.m
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
#import "NSUserDefaults.h"

MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString          *NSGlobalDomain       = @"NSGlobalDomain";

MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString          *NSArgumentDomain     = @"NSArgumentDomain";

MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL_VAR
NSString          *NSRegistrationDomain = @"NSRegistrationDomain";

static NSString   *NSApplicationDomain  = @"NSApplicationDomain";


@implementation NSUserDefaults

+ (NSUserDefaults *) standardUserDefaults
{
   return( [NSUserDefaults sharedInstance]);
}


- (instancetype) init
{
   _domains    = [NSMutableDictionary new];
   _searchList = [[NSMutableArray alloc] initWithObjects:NSApplicationDomain, nil];

   return( self);
}


- (void) dealloc
{
   [_domains release];
   [_searchList release];
   [super dealloc];
}


- (id) objectForKey:(id) key
{
   NSDictionary   *domain;
   NSString       *name;
   id             value;

   NSParameterAssert( [key isKindOfClass:[NSString class]]);

   for( name in _searchList)
   {
      domain = [_domains objectForKey:name];
      value  = [domain objectForKey:key];
      if( value)
         return( value);
   }
   return( nil);
}


static NSMutableDictionary   *applicationDomain( NSUserDefaults *self)
{
   NSMutableDictionary   *domain;

   domain = [self->_domains objectForKey:NSApplicationDomain];
   if( ! domain)
   {
      domain = [NSMutableDictionary new];
      [self->_domains setObject:domain
                         forKey:NSApplicationDomain];
      [domain release];
   }
   return( domain);
}


- (void) setObject:(id) value
            forKey:(id <NSObject, MulleObjCImmutableCopying>) key
{
   NSParameterAssert( [(NSObject *) key isKindOfClass:[NSString class]]);

   [applicationDomain( self) setObject:value
                               forKey:key];
}


- (void) removeObjectForKey:(id) key
{
   NSMutableDictionary  *domain;

   NSParameterAssert( [key isKindOfClass:[NSString class]]);

   domain = [_domains objectForKey:NSApplicationDomain];
   [domain removeObjectForKey:key];
}


- (void) registerDefaults:(NSDictionary *) defaults
{
   NSMutableDictionary  *dict;

   NSParameterAssert( [defaults isKindOfClass:[NSDictionary class]]);

   dict = [_domains objectForKey:NSRegistrationDomain];
   if( ! dict)
   {
      dict = [NSMutableDictionary dictionary];
      [_searchList addObject:NSRegistrationDomain];
   }
   [dict addEntriesFromDictionary:defaults];

   [_domains setObject:dict
                 forKey:NSRegistrationDomain];
}


- (NSDictionary *) dictionaryRepresentation
{
   NSMutableDictionary   *dict;
   NSDictionary          *domain;
   NSString              *name;

   dict  = [NSMutableDictionary dictionary];
   for( name in _searchList)
   {
      domain = [_domains objectForKey:name];
      [dict addEntriesFromDictionary:domain];
   }
   return( dict);
}


- (BOOL) synchronize
{
   return( NO);
}

@end


@implementation NSUserDefaults( Conveniences)

static id   objectValueOfClassForKey( NSUserDefaults *self, Class cls, NSString *key)
{
   id   value;

   value = [self objectForKey:key];
   if( ! [value isKindOfClass:cls])
      value = nil;
   return( value);
}


static id   objectValueOfSelectorForKey( NSUserDefaults *self, SEL sel, NSString *key)
{
   id   value;

   value = [self objectForKey:key];
   if( ! [value respondsToSelector:sel])
      value = nil;
   return( value);
}


- (NSInteger) integerForKey:(NSString *) key
{
   return( [objectValueOfSelectorForKey( self, @selector( integerValue), key) integerValue]);
}


- (float) floatForKey:(NSString *) key
{
   return( [objectValueOfSelectorForKey( self, @selector( floatValue), key) floatValue]);
}


- (double) doubleForKey:(NSString *) key
{
   return( [objectValueOfSelectorForKey( self, @selector( doubleValue), key) doubleValue]);
}



- (BOOL) boolForKey:(NSString *) key
{
   return( [objectValueOfSelectorForKey( self, @selector( boolValue), key) boolValue]);
}



- (NSString *) stringForKey:(NSString *) key
{
   return( objectValueOfClassForKey( self, [NSString class], key));
}


- (NSArray *) arrayForKey:(NSString *) key
{
   return( objectValueOfClassForKey( self, [NSArray class], key));
}


- (NSDictionary *) dictionaryForKey:(NSString *) key
{
   return( objectValueOfClassForKey( self, [NSDictionary class], key));
}


- (NSData *) dataForKey:(NSString *) key
{
   return( objectValueOfClassForKey( self, [NSData class], key));
}


- (NSArray *) stringArrayForKey:(NSString *) key
{
   NSArray    *array;
   NSString   *s;
   Class      cls;

   cls   = [NSString class];
   array = objectValueOfClassForKey( self, [NSArray class], key);
   for( s in array)
      if( ! [s isKindOfClass:cls])
         return( nil);
   return( array);
}


- (void) setInteger:(NSInteger)value
             forKey:(NSString *) key
{
   [self setObject:[NSNumber numberWithDouble:value]
            forKey:key];
}


- (void) setFloat:(float) value
           forKey:(NSString *) key
{
   [self setObject:[NSNumber numberWithDouble:value]
            forKey:key];
}


- (void) setDouble:(double) value
            forKey:(NSString *) key
{
   [self setObject:[NSNumber numberWithDouble:value]
            forKey:key];
}


- (void) setBool:(BOOL) value
          forKey:(NSString *) key
{
   [self setObject:[NSNumber numberWithBool:value]
            forKey:key];
}

@end



//
//  NSUserDefaults.h
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
#import "import.h"


//
// this is a Darwin concept
// on Linux, its .config
// on Windows its the registry
//
@interface NSUserDefaults : NSObject < MulleObjCSingleton>

{
   NSMutableArray        *_searchList;
   NSMutableDictionary   *_domains;
}

+ (NSUserDefaults *)  standardUserDefaults;

- (instancetype) init;

- (id) objectForKey:(id) key;
- (void) setObject:(id) value
            forKey:(id <NSObject, MulleObjCImmutableCopying>) key;
- (void) removeObjectForKey:(id) key;

- (void) registerDefaults:(NSDictionary *) registrationDictionary;


- (NSDictionary *) dictionaryRepresentation;
- (BOOL) synchronize;

@end


@interface NSUserDefaults( Future) < MulleObjCFuture>

+ (void) resetStandardUserDefaults;

@end



// most of these will probably never be implemented, as they are
// useless in a cross-platform setting
// @interface NSUserDefaults( Todo)
//
// - (instancetype) initWithUser:(NSString *) username;
// - (void) addSuiteNamed:(NSString *) suiteName;
// - (void) removeSuiteNamed:(NSString *) suiteName;
//
// - (NSArray *) volatileDomainNames;
// - (NSDictionary *) volatileDomainForName:(NSString *) domainName;
// - (void) setVolatileDomain:(NSDictionary *) domain
//                    forName:(NSString *) domainName;
// - (void) removeVolatileDomainForName:(NSString *) domainName;
//
// - (NSArray *) persistentDomainNames;
// - (NSDictionary *) persistentDomainForName:(NSString *) domainName;
// - (void)  setPersistentDomain:(NSDictionary *)  domain
//                      forName:(NSString *) domainName;
// - (void)  removePersistentDomainForName:(NSString *)  domainName;
//
// @end


@interface NSUserDefaults ( Conveniences)

- (BOOL)                 boolForKey:(NSString *) key;
- (double)             doubleForKey:(NSString *) key;
- (float)               floatForKey:(NSString *) key;
- (NSArray *)           arrayForKey:(NSString *) key;
- (NSArray *)     stringArrayForKey:(NSString *) key;
- (NSData *)             dataForKey:(NSString *) key;
- (NSDictionary *) dictionaryForKey:(NSString *) key;
- (NSInteger)         integerForKey:(NSString *) key;
- (NSString *)         stringForKey:(NSString *) key;

- (void) setInteger:(NSInteger)value
             forKey:(NSString *) key;
- (void) setFloat:(float) value
           forKey:(NSString *) key;
- (void) setDouble:(double) value
            forKey:(NSString *) key;
- (void) setBool:(BOOL) value
          forKey:(NSString *) key;

@end

MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL
NSString   *NSGlobalDomain;

MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL
NSString   *NSArgumentDomain;

MULLE_OBJC_OS_BASE_FOUNDATION_GLOBAL
NSString   *NSRegistrationDomain;


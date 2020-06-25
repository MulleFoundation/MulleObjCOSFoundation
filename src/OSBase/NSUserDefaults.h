/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSUserDefaults.h is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
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
+ (void) resetStandardUserDefaults;

- (instancetype) init;

- (id) objectForKey:(id) key;
- (void) setObject:(id) value
            forKey:(id <NSCopying>) key;
- (void) removeObjectForKey:(id) key;

- (void) registerDefaults:(NSDictionary *) registrationDictionary;


- (NSDictionary *) dictionaryRepresentation;
- (BOOL) synchronize;

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

extern NSString   *NSGlobalDomain;
extern NSString   *NSArgumentDomain;
extern NSString   *NSRegistrationDomain;


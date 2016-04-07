/*
 *  MulleFoundation - A tiny Foundation replacement
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
#import <MulleObjCFoundation/MulleObjCFoundation.h>


@interface NSUserDefaults : NSObject
{
   NSMutableArray        *_searchList;
   NSMutableDictionary   *_domains;
}

+ (NSUserDefaults *)  standardUserDefaults;
+ (void) resetStandardUserDefaults;

- (id) init;
- (id) initWithUser:(NSString *) username;

- (id) objectForKey:(NSString *) key;
- (void) setObject:(id) value 
            forKey:(NSString *) key;
- (void) removeObjectForKey:(id) key;

- (void) registerDefaults:(NSDictionary *) registrationDictionary;

- (void) addSuiteNamed:(NSString *) suiteName;
- (void) removeSuiteNamed:(NSString *) suiteName;

- (NSDictionary *) dictionaryRepresentation;

- (NSArray *) volatileDomainNames;
- (NSDictionary *) volatileDomainForName:(NSString *) domainName;
- (void) setVolatileDomain:(NSDictionary *) domain 
                   forName:(NSString *) domainName;
- (void) removeVolatileDomainForName:(NSString *) domainName;

- (NSArray *) persistentDomainNames;
- (NSDictionary *) persistentDomainForName:(NSString *) domainName;
- (void)  setPersistentDomain:(NSDictionary *)  domain 
                     forName:(NSString *) domainName;
- (void)  removePersistentDomainForName:(NSString *)  domainName;

- (BOOL) synchronize;

@end


@interface NSUserDefaults ( _Conveniences)

- (NSInteger) integerForKey:(NSString *) key;
- (NSString *) stringForKey:(NSString *) key;
- (NSArray *) arrayForKey:(NSString *) key;
- (NSDictionary *) dictionaryForKey:(NSString *) key;
- (NSData *) dataForKey:(NSString *) key;
- (NSArray *) stringArrayForKey:(NSString *) key;
- (NSInteger)integerForKey:(NSString *) key;
- (float) floatForKey:(NSString *) key;
- (double) doubleForKey:(NSString *) key;
- (BOOL) boolForKey:(NSString *) key;

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


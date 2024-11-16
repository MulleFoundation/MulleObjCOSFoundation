/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSBundle.h is a part of MulleFoundation
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
// there will be subclasses for Frameworks proper
// and unix "spread" over multiple folders kinda bundles
//
// MEMO: NSBundle is declared as MulleObjCThreadSafe, so additional methods
//       added by subclasses must be thread safe as well.
//
@interface NSBundle : NSObject <MulleObjCThreadSafe>
{
   // these are read only set by init
   NSString              *_path;
   NSLock                *_lock;  // used for lazy resources

   void                  *_handle;
   void                  *_startAddress;
   void                  *_endAddress;

   //
   // localization, we cache only for a single languageCode
   // because this is "usual". Protected by lock
   //
   NSString              *_languageCode;
   NSMutableDictionary   *_localizedStringTables;

@private
   id                    _infoDictionary;      // lazy can be NSNull

@private
   mulle_atomic_id_t     _executablePath;      // for "already loaded" bundles
   mulle_atomic_id_t     _resourcePath;        // for "already loaded" bundles
}


+ (NSBundle *) mainBundle;
+ (NSArray *) allFrameworks;
+ (NSArray *) allBundles;
+ (NSBundle *) bundleWithPath:(NSString *) path;
+ (NSBundle *) bundleWithIdentifier:(NSString *) identifier;

- (instancetype) initWithPath:(NSString *) fullPath;

- (NSString *) bundleIdentifier;
- (Class) principalClass;

- (NSString *) resourcePath;
- (NSString *) executablePath;
- (NSString *) bundlePath;
- (BOOL) isLoaded;

- (NSString *) pathForResource:(NSString *) name
                        ofType:(NSString *) extension;
- (NSString *) pathForResource:(NSString *) name
                        ofType:(NSString *) extension
                   inDirectory:(NSString *) subpath;
- (NSArray *) pathsForResourcesOfType:(NSString *) extension
                          inDirectory:(NSString *) subpath;

- (Class) classNamed:(NSString *) className;

- (NSString *) localizedStringForKey:(NSString *) key
                               value:(NSString *) comment
                               table:(NSString *) tableName;

- (id) objectForInfoDictionaryKey:(NSString *) key;
- (NSDictionary *) infoDictionary;

- (NSString *) developmentLocalization;

// these aren't doing anything ATM, they are just here because MulleEOF
// wants them
- (NSArray *) localizations;
- (NSArray *) preferredLocalizations;
- (NSDictionary *) localizedInfoDictionary;

@end


// stuff we need to implement
@interface NSBundle ( Future)

// default returns NO
+ (BOOL) isBundleFilesystemExtension:(NSString *) extension;

+ (NSString *) pathForResource:(NSString *) name
                        ofType:(NSString *) extension
                   inDirectory:(NSString *) bundlePath;

+ (NSArray *) pathsForResourcesOfType:(NSString *) extension
                          inDirectory:(NSString *) bundlePath;

- (NSString *) pathForAuxiliaryExecutable:(NSString *) executableName;
- (NSArray *) pathsForResourcesOfType:(NSString *) extension
                          inDirectory:(NSString *) subpath;
- (NSString *) privateFrameworksPath;
- (NSString *) sharedFrameworksPath;
- (NSString *) sharedSupportPath;
- (NSString *) builtInPlugInsPath;

@end


// OS Specific stuff stuff we need to implement
@interface NSBundle ( OSSpecific)

// rename from load because of the wrong type
- (BOOL) loadBundle;
- (BOOL) unloadBundle;  // returns NO if it wasn't loaded (like a linked shared lib)

//
// almost useless in statically linked configurations, because it will always
// be the mainBundle. Ideas: executable collects resources from libraries
// stores where ?
//
+ (NSBundle *) bundleForClass:(Class) aClass;

@end


MULLE_OBJC_OSBASE_FOUNDATION_GLOBAL NSString   *NSLoadedClasses;
MULLE_OBJC_OSBASE_FOUNDATION_GLOBAL NSString   *NSBundleDidLoadNotification;

MULLE_OBJC_OSBASE_FOUNDATION_GLOBAL
NSString   *MulleObjCBundleLocalizedStringFromTable( NSBundle *bundle,
                                                     NSString *tableName,
                                                     NSString *key,
                                                     NSString *value);


#define NSLocalizedString( key, comment) \
   MulleObjCBundleLocalizedStringFromTable( [NSBundle mainBundle], nil, (key), @"")

#define NSLocalizedStringFromTable( key, table, comment) \
   MulleObjCBundleLocalizedStringFromTable( [NSBundle mainBundle], (table), (key), @"")

#define NSLocalizedStringFromTableInBundle( key, table, bundle, comment) \
   MulleObjCBundleLocalizedStringFromTable( (bundle), (table), (key), @"")

#define NSLocalizedStringWithDefaultValue( key, table, bundle, value, comment) \
   MulleObjCBundleLocalizedStringFromTable( (bundle), (table), (key), (value))


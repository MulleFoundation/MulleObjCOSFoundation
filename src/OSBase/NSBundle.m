/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSBundle.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
// define, that make things POSIXly
#define _XOPEN_SOURCE 700

#import "NSBundle.h"
#import "NSBundle-Private.h"

// other files in this library
#import "NSDirectoryEnumerator.h"
#import "NSFileManager.h"
#import "NSLog.h"
#import "NSProcessInfo.h"
#import "NSDictionary+OSBase.h"
#import "NSString+CString.h"
#import "NSString+OSBase.h"
#import "NSUserDefaults.h"

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#import <MulleObjC/NSDebug.h>
#include <dlfcn.h>


NSString   *NSLoadedClasses             = @"NSLoadedClasses";
NSString   *NSBundleDidLoadNotification = @"NSBundleDidLoadNotification";


#define BUNDLE_REGISTRATION_DEBUG


@interface NSObject( _NS)

- (BOOL) __isNSNull;
- (BOOL) __isNSString;

@end


@implementation NSBundle

MULLE_OBJC_DEPENDS_ON_LIBRARY( MulleObjCStandardFoundation);

static struct
{
   mulle_thread_mutex_t   _lock;
   NSMutableDictionary    *_registeredBundleInfo;
   BOOL                   _haveDiscovered;
} Self;


static inline void   SelfLock( void)
{
   mulle_thread_mutex_lock( &Self._lock);
}


static inline void   SelfUnlock( void)
{
   mulle_thread_mutex_unlock( &Self._lock);
}


+ (void) initialize
{
   Self._registeredBundleInfo = [NSMutableDictionary new];
}


// +finalize solely exists for the benefit of NSBundle...
+ (void) finalize
{
   @autoreleasepool
   {
#ifdef BUNDLE_REGISTRATION_DEBUG
      fprintf( stderr, "Releasing all registered bundles\n");
#endif
      [Self._registeredBundleInfo autorelease];
      Self._registeredBundleInfo = nil;
   }
}


// should pair load with unload, otherwise +initialize may run too late
+ (void) load
{
   if( mulle_thread_mutex_init( &Self._lock))
   {
      fprintf( stderr, "%s could not get a mutex\n", __FUNCTION__);
      abort();
   }
}


+ (void) unload
{
   mulle_thread_mutex_done( &Self._lock);
}


// future "object" trace support
+ (NSUInteger) _getOwnedObjects:(id *) objects
                          count:(NSUInteger) count
{
   return( MulleObjCCopyObjects( objects, count, 1, Self._registeredBundleInfo));
}


static NSBundle  *get_or_register_bundle( NSBundle *bundle, NSString *path)
{
   NSBundle   *other;

   SelfLock();
   {
      other = [Self._registeredBundleInfo objectForKey:path];
      if( ! other && bundle)
      {
         [Self._registeredBundleInfo setObject:bundle
                                        forKey:path];
#ifdef BUNDLE_REGISTRATION_DEBUG
         mulle_fprintf( stderr, "Added bundle %p for path %@\n", bundle, path);
#endif
         if( NSDebugEnabled)
            NSLog( @"Added Bundle %p for path \"%@\"", bundle, path);
         other = bundle;
      }
      else
      {
#ifdef BUNDLE_REGISTRATION_DEBUG
         if( other)
            mulle_fprintf( stderr, "Found bundle %p for path %@\n", other, path);
#endif
      }

      other = [[other retain] autorelease];
   }
   SelfUnlock();

   return( other);
}


static void   deregister_bundle( NSBundle *bundle, NSString *path)
{
   assert( bundle);
   assert( path);

   //
   // a different bundle, can not live under the same name
   //
   SelfLock();
   {
      NSBundle   *other;

      other = [Self._registeredBundleInfo objectForKey:path];
      if( other == bundle)
      {
         [Self._registeredBundleInfo removeObjectForKey:path];
#ifdef BUNDLE_REGISTRATION_DEBUG
         mulle_fprintf( stderr, "Removed bundle %p for path %@\n", bundle, path);
#endif
      }
   }
   SelfUnlock();
}


//
// This indirection was supposed to be used by subprojects.
//
// you can pass a nil for bundle, to just lookup
//
NSBundle  *(*NSBundleGetOrRegisterBundleWithPath)( NSBundle *bundle, NSString *path) = get_or_register_bundle;
void       (*NSBundleDeregisterBundleWithPath)( NSBundle *bundle, NSString *path) = deregister_bundle;


+ (BOOL) isBundleFilesystemExtension:(NSString *) extension
{
   return( NO);
}


- (id) __mulleInitWithPath:(NSString *) fullPath
         sharedLibraryInfo:(struct _MulleObjCSharedLibrary *) libInfo
{
   NSFileManager       *manager;
   BOOL                isDir;
   BOOL                flag;

   fullPath = [fullPath stringByStandardizingPath];
   fullPath = [fullPath stringByResolvingSymlinksInPath];

   manager = [NSFileManager defaultManager];
   flag    = [manager fileExistsAtPath:fullPath
                           isDirectory:&isDir];

   //
   // bundles must be directories, except we'll allow a special extension
   // bundlefs later on.

   //
   // But that doesn't work for the mainbundle... and .so so maybe not
   //
   //if( flag && ! isDir && ! [[self class] isBundleFilesystemExtension:[_path pathExtension]])
   //   flag = NO;

   if( ! flag)
   {
      [self release];
      return( nil);
   }

   self = [self init];  // should be done by subcategory

   if( libInfo)
   {
      MulleObjCAtomicIdSetCopy( &_executablePath, libInfo->path);
      _startAddress   = libInfo->start;
      _endAddress     = libInfo->end;
      _handle         = libInfo->handle;
   }

   _path = [fullPath copy];
   _lock = [NSLock new];

   return( self);
}


- (id) _mulleInitWithPath:(NSString *) fullPath
        sharedLibraryInfo:(struct _MulleObjCSharedLibrary *) libInfo
{
   NSBundle   *bundle;

   if( ! [fullPath isAbsolutePath])
      MulleObjCThrowInvalidArgumentException( @"\"%@\" is not an absolute path", fullPath);

   // speculatively assume fullPath is already correct
   bundle = (*NSBundleGetOrRegisterBundleWithPath)( NULL, fullPath);
   if( ! bundle)
   {
      self = [self __mulleInitWithPath:fullPath
                     sharedLibraryInfo:libInfo];
      if( ! self)
         return( self);

      // use properly canonicalized _path for second check
      bundle = (*NSBundleGetOrRegisterBundleWithPath)( self, _path);
      if( bundle == self)
      {
#ifdef BUNDLE_REGISTRATION_DEBUG
         fprintf( stderr, "Bundle %p lives\n", self);
#endif
         return( self);
      }
   }

   [bundle retain];
   [self release];
   return( bundle);
}


//
// stage it, so that we can intercept it
//
- (instancetype) initWithPath:(NSString *) fullPath
{
   return( [self _mulleInitWithPath:fullPath
                  sharedLibraryInfo:NULL]);
}


- (void) finalize
{
   [self unloadBundle]; // sets handle to NULL
   if( _path)
      (*NSBundleDeregisterBundleWithPath)( self, _path);

   [super finalize];
}


- (void) dealloc
{
#ifdef BUNDLE_REGISTRATION_DEBUG
   fprintf( stderr, "Bundle %p dies\n", self);
#endif

   [_path release];
   MulleObjCAtomicIdRelease( &_executablePath);
   MulleObjCAtomicIdRelease( &_resourcePath);

   [_languageCode release];
   [_localizedStringTables release];
   [_infoDictionary release];
   [_lock release];

   [super dealloc];
}


+ (NSBundle *) mainBundle
{
   NSBundle                         *bundle;
   NSString                         *path;
   struct _MulleObjCSharedLibrary   libInfo;

   libInfo.path   = [[NSProcessInfo processInfo] _executablePath];
   NSParameterAssert( [libInfo.path length]);
   libInfo.start  = 0;
   libInfo.end    = 0;
   libInfo.handle = NULL;
   path           = [self _mainBundlePathForExecutablePath:libInfo.path];

   //
   // return possibly already registered bundle here
   //
   bundle        = [[[self alloc] _mulleInitWithPath:path
                                   sharedLibraryInfo:&libInfo] autorelease];
   return( bundle);
}


// a bundle is
//
// a) the main bundle
// b) anything loaded with NSBundle (except framework) is this true ??
//
//
// all shared libraries, except those listed under allBundles
//

+ (NSDictionary *) mulleRegisteredBundleInfo
{
   NSBundle                         *bundle;
   NSString                         *path;
   NSString                         *mainExecutablePath;
   NSBundle                         *mainBundle;
   NSData                           *sharedLibraryInfo;
   struct _MulleObjCSharedLibrary   *infoLibs;
   struct _MulleObjCSharedLibrary   *sentinel;
   NSUInteger                       nInfoLibs;
   NSDictionary                     *dict;

   SelfLock();
   {
      if( ! Self._haveDiscovered)
      {
         SelfUnlock();  // unlock now, since NSBundleGetOrRegisterBundleWithPath
                        // will lock and unlock again

         mainBundle         = [self mainBundle];
         mainExecutablePath = [mainBundle executablePath];
         assert( mainExecutablePath);

         sharedLibraryInfo = [self _allSharedLibraries];
         infoLibs          = [sharedLibraryInfo bytes];
         nInfoLibs         = [sharedLibraryInfo length] / sizeof( struct _MulleObjCSharedLibrary);
         sentinel          = &infoLibs[ nInfoLibs];
         while( infoLibs < sentinel)
         {
            path = [self _bundlePathForExecutablePath:infoLibs->path];

            // superflous check ?
            if( ! mainExecutablePath || ! [path isEqualToString:mainExecutablePath])
            {
               bundle = [[[NSBundle alloc] _mulleInitWithPath:path
                                            sharedLibraryInfo:infoLibs] autorelease];
               (*NSBundleGetOrRegisterBundleWithPath)( bundle, [bundle bundlePath]);
            }
            infoLibs++;
         }

         SelfLock();

         Self._haveDiscovered = YES;
      }

      dict = [NSDictionary dictionaryWithDictionary:Self._registeredBundleInfo];
   }
   SelfUnlock();

   return( dict);
}


+ (NSArray *) _allBundlesWhichAreFrameworks:(BOOL) flag
{
   NSBundle         *bundle;
   NSString         *path;
   NSMutableArray   *array;
   NSDictionary     *bundleInfo;
   BOOL             isFramework;

   bundleInfo = [self mulleRegisteredBundleInfo];

   array = [NSMutableArray array];
   for( path in bundleInfo)
   {
      isFramework = [[path pathExtension] isEqualToString:@"framework"];
      if( (! flag) ^ isFramework)
      {
         bundle = [bundleInfo objectForKey:path];
         [array addObject:bundle];
      }
   }
   return( array);
}


+ (NSArray *) allFrameworks
{
   return( [self _allBundlesWhichAreFrameworks:YES]);
}


+ (NSArray *) allBundles
{
   return( [self _allBundlesWhichAreFrameworks:NO]);
}


//
// could be a bottleneck in da future, then "just" make the
// bundle container a NSMapTable and index it with a second NSMapTable
// keyed by handle
//
+ (NSBundle *) _bundleForHandle:(void *) handle
{
   NSBundle   *bundle;

   for( bundle in [self allBundles])
      if( bundle->_handle == handle)
         return( bundle);
   return( nil);
}


+ (NSBundle *) bundleWithPath:(NSString *) path
{
   return( [[[self alloc] initWithPath:path] autorelease]);
}


+ (NSBundle *) _bundleWithPath:(NSString *) path
                executablePath:(NSString *) executablePath
{
   struct _MulleObjCSharedLibrary  libInfo;

   libInfo.path   = executablePath;
   libInfo.start  = 0;
   libInfo.end    = 0;
   libInfo.handle = 0;

   return( [[[self alloc] _mulleInitWithPath:path
                           sharedLibraryInfo:&libInfo] autorelease]);
}


+ (NSBundle *) bundleWithIdentifier:(NSString *) identifier
{
   NSString       *path;
   NSBundle       *bundle;
   NSDictionary   *bundleInfo;

   bundleInfo = [self mulleRegisteredBundleInfo];
   for( path in bundleInfo)
   {
      bundle = [bundleInfo objectForKey:path];
      if( [identifier isEqualToString:[bundle bundleIdentifier]])
         return( bundle);
   }

   // for static configurations
   if( [identifier isEqualToString:@"com.mulle-kybernetik.foundation"])
      return( [self mainBundle]);

   return( nil);
}


- (NSString *) resourcePath
{
   NSString   *value;

   value = MulleObjCAtomicIdGetLazyCopy( &_resourcePath,
                                         self,
                                         @selector( _resourcePath));

   return( value);
}


- (NSString *) executablePath
{
   NSString   *value;

   value = MulleObjCAtomicIdGetLazyCopy( &_executablePath,
                                         self,
                                         @selector( _executablePath));

   return( value);
}


- (NSString *) bundlePath
{
   return( _path);
}


- (BOOL) preflightAndReturnError:(NSError **) error
{
   return( YES);
}


// for all intents and purposes static linked libraries are also "loaded"
// but we never unload them
- (BOOL) isLoaded
{
   return( _handle != NULL);
}


- (void) willLoad
{
   assert( _handle == NULL);
}


- (void) didLoad
{
   assert( _handle != NULL);
   //
   // would have to run over the whole runtime to find classes and categories
   // that are inside _handle, that's too slow, and I don't care.
   // Howto:
   //    walk runtime over categories and classes, find the respective
   //    loadclass and loadcategory. Use dladdr to find the containing shared
   //    object.
   //
   [[NSNotificationCenter defaultCenter] postNotificationName:NSBundleDidLoadNotification
                                                       object:self
                                                    userInfo:@{
   @"note": @"NSLoadedClasses is alway nil mulle-objc" }];
}


//
// 1. Global (nonlocalized) resources
// 2. Region-specific localized resources (based on the user’s region preferences)
// 3. Language-specific localized resources (based on the user’s language preferences)
// 4. Development language resources (as specified by the CFBundleDevelopmentRegion key in the bundle’s Info.plist file)
//
// Also should check Base.lproj as a fallback (I guess)
//
- (NSString *) pathForResource:(NSString *) name
                        ofType:(NSString *) extension
                   inDirectory:(NSString *) directory
{
   NSFileManager   *manager;
   NSString        *root;
   NSString        *path;
   NSString        *filename;
   NSString        *subdir;
   NSString        *language;
   NSString        *translated;
   NSLocale        *locale;
   NSLocale        *enLocale;

   root = [self resourcePath];
   root = [root stringByAppendingPathComponent:directory];

   filename = [name stringByAppendingPathExtension:extension];
   path     = [root stringByAppendingPathComponent:filename];

   manager  = [NSFileManager defaultManager];
   if( [manager fileExistsAtPath:path])
      return( path);

   //
   // now comes the OS specific part really
   // Do we really want lproj on Linux ?
   //
   locale   = [NSLocale autoupdatingCurrentLocale];
   language = [locale languageCode];
   subdir   = [language stringByAppendingPathExtension:@"lproj"];
   path     = [root stringByAppendingPathComponent:subdir];
   path     = [path stringByAppendingPathComponent:filename];

   if( [manager fileExistsAtPath:path])
      return( path);

   //
   // if de.lproj, doesn't find anything look for German.lproj
   // probably only on the Mac though
   //
   enLocale   = [NSLocale localeWithLocaleIdentifier:@"en_US"];
   translated = [enLocale localizedStringForLanguageCode:language];
   subdir     = [translated stringByAppendingPathExtension:@"lproj"];
   path       = [root stringByAppendingPathComponent:subdir];
   path       = [path stringByAppendingPathComponent:filename];

   if( [manager fileExistsAtPath:path])
      return( path);

   return( nil);
}


//
// Apple's version is actually quite different, as it does
// exhaustive searches (e.g. any PNG file)
// But this doesn't
//
- (NSString *) pathForResource:(NSString *) name
                        ofType:(NSString *) extension
{
   return( [self pathForResource:name
                          ofType:extension
                     inDirectory:nil]);
}


+ (NSArray *) _pathsWithExtension:(NSString *) extension
                      inDirectory:(NSString *) path
{
   NSFileManager           *manager;
   NSDirectoryEnumerator   *rover;
   NSMutableArray          *array;
   NSString                *file;
   NSAutoreleasePool       *pool;

   manager = [NSFileManager defaultManager];
   rover   = [manager enumeratorAtPath:path];
   if( ! rover)
      return( nil);

   array = [NSMutableArray array];

   pool = NSPushAutoreleasePool( 0);
   while( file = [rover nextObject])
   {
      if( [[file pathExtension] isEqualToString:extension])
         [array addObject:[path stringByAppendingPathComponent:file]];
      [rover skipDescendants];  // do it always
   }
   NSPopAutoreleasePool( pool);

   return( array);
}


- (NSArray *) pathsForResourcesOfType:(NSString *) extension
                          inDirectory:(NSString *) subpath
{
   NSString   *root;
   NSString   *path;

   root = [self resourcePath];
   path = root;
   if( subpath)
   {
      // search just here ?
      path = [root stringByAppendingPathComponent:subpath];
   }

   return( [NSBundle _pathsWithExtension:extension
                             inDirectory:path]);
}


// just guesses
+ (NSString *)  _OSIdentifier
{
   switch( [[NSProcessInfo processInfo] operatingSystem])
   {
   case NSWindowsNTOperatingSystem :
   case NSWindows95OperatingSystem : return( @"Windows");
   case NSSolarisOperatingSystem   : return( @"Solaris");
   case NSHPUXOperatingSystem      : return( @"HPUX");
   case NSDarwinOperatingSystem    : return( @"MacOS");
   case NSSunOSOperatingSystem     : return( @"SunOS");
   case NSOSF1OperatingSystem      : return( @"OSF1");
   case NSLinuxOperatingSystem     : return( @"Linux");
   case NSBSDOperatingSystem       : return( @"BSD");
   }
   return( @"???");
}


+ (NSString *) _mainBundlePathForExecutablePath:(NSString *) executablePath
{
   // default, overridden by Darwin
   return( [executablePath stringByDeletingLastPathComponent]);
}


+ (NSString *) _bundlePathForExecutablePath:(NSString *) executablePath
{
   // default, overridden by Darwin
   return( [executablePath stringByDeletingLastPathComponent]);
}


- (BOOL) mulleContainsAddress:(void *) address
{
   return( (uintptr_t) _startAddress >= (uintptr_t)  address &&
           (uintptr_t) _endAddress <= (uintptr_t)  address);
}


//
// this is fallback code in case platform has no dladdr
//
+ (NSBundle *) bundleForClass:(Class) aClass
{
   NSBundle       *bundle;
   NSDictionary   *bundleInfo;
   NSString       *bundlePath;
   void           *classAddress;

   if( ! aClass)
      return( nil);

   classAddress = MulleObjCClassGetLoadAddress( aClass);
   // if there is no load address, its genrated dynamicall at runtime
   // e.g. NSZombie
   // if there is no load address, its genrated dynamicall at runtime
   // e.g. NSZombie
   if( ! classAddress)
      return( [NSBundle mainBundle]);

   //
   // it would be nice to binary search the bundles
   // but it doesn't seem worth to extract them into
   // an NSArray and sort them before searching here
   //
   bundleInfo = [self mulleRegisteredBundleInfo];
   for( bundlePath in bundleInfo)
   {
      bundle = [bundleInfo objectForKey:bundlePath];
      if( [bundle mulleContainsAddress:classAddress])
         return( bundle);
   }

   // assume all classes not in a shared library is part of an exe
   return( [NSBundle mainBundle]);
}


- (NSString *) _stringForKey:(NSString *) key
                      locale:(NSLocale *) locale
                       table:(NSString *) tableName
{
   return( key);
}


- (id) objectForInfoDictionaryKey:(NSString *)key
{
   // this returns the localized value according to dox
   NSString   *value;

   value = [[self infoDictionary] objectForKey:key];
   if( [value __isNSString])
      return( [self localizedStringForKey:value
                                    value:nil
                                    table:@"InfoPlist"]);
   return( value);
}


static id  readDictionary( NSBundle *self, NSString *name, NSString *type)
{
   NSDictionary   *dict;
   NSString       *path;

   path = [self pathForResource:name
                         ofType:type];
   dict = [NSDictionary dictionaryWithContentsOfFile:path];
   return( dict);
}


static id  readDictionaryOrNull( NSBundle *self, NSString *name, NSString *type)
{
   NSDictionary   *dict;

   dict = readDictionary( self, name, type);
   if( ! dict)
      return( [NSNull null]);
   return( dict);
}


// assume infoDictionary is immutable!
- (NSDictionary *) infoDictionary
{
   NSDictionary   *dict;

   for(;;)
   {
      if( _infoDictionary)
         return( _infoDictionary == [NSNull null] ? nil : _infoDictionary);

      dict = readDictionaryOrNull( self, @"Info", @"plist");
      [_lock lock];
      {
         if( ! _infoDictionary)
            _infoDictionary = [dict retain];
      }
      [_lock unlock];
   }
}


- (NSString *) localizedStringForKey:(NSString *) key
                               value:(NSString *) value
                               table:(NSString *) tableName
{
   NSString       *localizedValue;
   NSLocale       *locale;
   NSString       *languageCode;
   NSDictionary   *table;
   NSDictionary   *dict;

   NSParameterAssert( ! key || [key isKindOfClass:[NSString class]]);
   NSParameterAssert( ! tableName || [tableName isKindOfClass:[NSString class]]);
   NSParameterAssert( ! value || [value isKindOfClass:[NSString class]]);

   // see: https://developer.apple.com/documentation/foundation/nsbundle/1417694-localizedstringforkey?language=objc
   if( ! key)
      return( value ? value : @"");

   if( ! [tableName length])
      tableName = @"LocalizedStrings";

   locale       = [NSLocale autoupdatingCurrentLocale];
   languageCode = [locale languageCode];

   [_lock lock];
   {
      if( ! [_languageCode isEqualToString:languageCode])
      {
         [_languageCode autorelease];
         [_localizedStringTables autorelease];

         _languageCode          = [languageCode copy];
         _localizedStringTables = [NSMutableDictionary new];
      }

      table = [_localizedStringTables objectForKey:tableName];
      if( ! table)
      {
         // don't lock when hitting the filesystem
         {
            [_lock unlock];
         }
         dict = readDictionaryOrNull( self, tableName, @"strings");
         {
            [_lock lock];
         }

         // so recheck assumption, that there is nothing here yet
         table = [_localizedStringTables objectForKey:tableName];
         if( ! table)
         {
            [_localizedStringTables setObject:dict
                                       forKey:tableName];
            table = dict;
         }
      }
   }
   [_lock unlock];

   if( [table __isNSNull])
      table = nil;

   localizedValue = [table objectForKey:key];
   if( ! [localizedValue length])
   {
      if( [[NSUserDefaults standardUserDefaults] boolForKey:@"NSShowNonLocalizedStrings"])
         NSLog( @"Localization for %@ and language %@ is missing", key, [locale languageCode]);
      return( key);
   }
   return( localizedValue);
}


NSString   *MulleObjCBundleLocalizedStringFromTable( NSBundle *bundle,
                                                     NSString *tableName,
                                                     NSString *key,
                                                     NSString *value)
{
   NSCParameterAssert( [bundle isKindOfClass:[NSBundle class]]);

   return( [bundle localizedStringForKey:key
                                   value:value
                                   table:tableName]);
}


//
// we don't "do" NSExecutableKey
// we incidentally also don't do NSBundleDidLoadNotification
// properly
//
- (Class) classNamed:(NSString *) className
{
   if( ! [self isLoaded])
      [self loadBundle];

   if( ! className)
      return( nil);

   // THIS IS NOT CORRECT!
   return( NSClassFromString( className));
}


- (Class) principalClass
{
   NSString  *value;

   value = [[self infoDictionary] objectForKey:@"NSPrincipalClass"];
   return( [self classNamed:value]);
}


- (NSString *) bundleIdentifier
{
   // darwin will have CFBundleIdentifier
   return( [[self infoDictionary] objectForKey:@"NSBundleIdentifier"]);
}


- (NSString *) developmentLocalization
{
   // darwin will have CFBundleDevelopmentRegion
   return( [[self infoDictionary] objectForKey:@"NSBundleDevelopmentRegion"]);
}


- (NSArray *) localizations
{
   return( nil);
}


- (NSArray *) preferredLocalizations
{
   return( nil);
}


- (NSDictionary *) localizedInfoDictionary
{
   return( [self infoDictionary]);
}

@end


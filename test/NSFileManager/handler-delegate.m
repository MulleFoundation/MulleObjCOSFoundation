#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


@interface Handler : NSObject
{
   NSUInteger   _willCount;
   NSUInteger   _errorCount;
   BOOL         _proceed;
   NSString     *_lastPath;
}

- (void) reset;
- (void) setProceed:(BOOL) flag;
- (NSUInteger) willCount;
- (NSUInteger) errorCount;
- (NSString *) lastPath;

- (void) fileManager:(NSFileManager *) manager
     willProcessPath:(NSString *) path;
- (BOOL) fileManager:(NSFileManager *) manager
shouldProceedAfterError:(NSError *) error
    movingItemAtPath:(NSString *) srcPath
              toPath:(NSString *) dstPath;
- (BOOL) fileManager:(NSFileManager *) manager
shouldProceedAfterError:(NSError *) error
   copyingItemAtPath:(NSString *) srcPath
              toPath:(NSString *) dstPath;
- (BOOL) fileManager:(NSFileManager *) manager
shouldRemoveItemAtPath:(NSString *) path;
@end


@implementation Handler

- (void) reset
{
   _willCount  = 0;
   _errorCount = 0;
}

- (void) setProceed:(BOOL) flag  { _proceed = flag; }
- (NSUInteger) willCount         { return( _willCount); }
- (NSUInteger) errorCount        { return( _errorCount); }
- (NSString *) lastPath          { return( _lastPath); }

- (void) fileManager:(NSFileManager *) manager
     willProcessPath:(NSString *) path
{
   _willCount++;
}

- (BOOL) fileManager:(NSFileManager *) manager
shouldProceedAfterError:(NSError *) error
    movingItemAtPath:(NSString *) srcPath
              toPath:(NSString *) dstPath
{
   _errorCount++;
   return( _proceed);
}

- (BOOL) fileManager:(NSFileManager *) manager
shouldProceedAfterError:(NSError *) error
   copyingItemAtPath:(NSString *) srcPath
              toPath:(NSString *) dstPath
{
   _errorCount++;
   return( _proceed);
}

- (BOOL) fileManager:(NSFileManager *) manager
shouldRemoveItemAtPath:(NSString *) path
{
   _lastPath = path;
   return( _proceed);
}
@end


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSFileManager   *fileManager;
   Handler         *handler;

   fileManager = [NSFileManager defaultManager];
   handler     = [[Handler alloc] init];

   [fileManager removeItemAtPath:@"d" error:NULL];
   [fileManager createDirectoryAtPath:@"d"
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];
   [fileManager createFileAtPath:@"d/a" contents:[NSData data] attributes:nil];

   // deprecated removeFileAtPath:handler:
   show( @"remove.handler.ok", [fileManager removeFileAtPath:@"d/a"
                                                      handler:handler]);
   show( @"remove.handler.gone", [fileManager fileExistsAtPath:@"d/a"]);
   show( @"remove.handler.will", [handler willCount] == 1);
   show( @"remove.handler.missing", [fileManager removeFileAtPath:@"d/nope"
                                                           handler:handler] == NO);

   // delegate shouldRemoveItemAtPath:
   [fileManager createFileAtPath:@"d/b" contents:[NSData data] attributes:nil];
   [handler setProceed:NO];
   [fileManager setDelegate:handler];

   show( @"remove.delegate.deny", [fileManager removeItemAtPath:@"d/b" error:NULL] == NO);
   show( @"remove.delegate.kept", [fileManager fileExistsAtPath:@"d/b"]);
   show( @"remove.delegate.path", [[handler lastPath] isEqualToString:@"d/b"]);

   [handler setProceed:YES];
   show( @"remove.delegate.allow", [fileManager removeItemAtPath:@"d/b" error:NULL]);
   show( @"remove.delegate.gone", [fileManager fileExistsAtPath:@"d/b"]);
   [fileManager setDelegate:nil];

   // deprecated movePath:toPath:handler:
   [fileManager createFileAtPath:@"d/c" contents:[NSData data] attributes:nil];
   show( @"move.handler.ok", [fileManager movePath:@"d/c"
                                            toPath:@"d/c2"
                                           handler:handler]);
   show( @"move.handler.dst", [fileManager fileExistsAtPath:@"d/c2"]);

   [fileManager createFileAtPath:@"d/m1" contents:[NSData data] attributes:nil];
   [fileManager createFileAtPath:@"d/m2" contents:[NSData data] attributes:nil];

   [handler reset];
   [handler setProceed:NO];
   show( @"move.handler.fail", [fileManager movePath:@"d/m1"
                                              toPath:@"d/m2"
                                             handler:handler] == NO);
   show( @"move.handler.src.kept", [fileManager fileExistsAtPath:@"d/m1"]);
   show( @"move.handler.errors", [handler errorCount] == 1);

   [handler reset];
   [handler setProceed:YES];
   show( @"move.handler.proceed", [fileManager movePath:@"d/m1"
                                                 toPath:@"d/m2"
                                                handler:handler]);
   show( @"move.handler.proceed.src.kept", [fileManager fileExistsAtPath:@"d/m1"]);

   // deprecated copyPath:toPath:handler:
   show( @"copy.handler.ok", [fileManager copyPath:@"d/m2"
                                            toPath:@"d/m2copy"
                                           handler:handler]);
   show( @"copy.handler.dst", [fileManager fileExistsAtPath:@"d/m2copy"]);

   [handler reset];
   [handler setProceed:YES];
   show( @"copy.handler.proceed", [fileManager copyPath:@"d/m2"
                                                 toPath:@"d/m2copy"
                                                handler:handler]);
   show( @"copy.handler.errors", [handler errorCount] == 1);
   show( @"copy.handler.no.handler.fail", [fileManager copyPath:@"d/m2"
                                                         toPath:@"d/m2copy"
                                                        handler:nil] == NO);

   [fileManager removeItemAtPath:@"d" error:NULL];
   [handler release];
   return( 0);
}

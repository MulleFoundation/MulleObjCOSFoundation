//
//  resolving-symlinks.m
//  MulleObjCOSFoundation
//
//  Regression test for -stringByResolvingSymlinksInPath. A symlink with a
//  relative target must be resolved against the directory of the link, not
//  against the current directory. Otherwise an absolute path in yields a
//  relative path out and NSBundle refuses a perfectly good library.
//


#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   test( char *label, NSString *path, NSString *expect)
{
   NSFileManager   *manager;
   NSString        *resolved;
   BOOL            passed;

   manager  = [NSFileManager defaultManager];
   resolved = [path stringByResolvingSymlinksInPath];

   passed = [resolved isAbsolutePath] &&
            [resolved isEqualToString:expect] &&
            [manager fileExistsAtPath:resolved];

   mulle_printf( "%s: %s\n", label, passed ? "passed" : "failed");
}


int   main( int argc, char *argv[])
{
   NSFileManager   *manager;
   NSString        *base;
   NSString        *dir;
   NSString        *target;
   NSString        *link;
   NSString        *abslink;
   NSString        *chain1;
   NSString        *chain2;

   manager = [NSFileManager defaultManager];

   [manager removeItemAtPath:@"resolving-symlinks-work"
                       error:NULL];
   [manager createDirectoryAtPath:@"resolving-symlinks-work"
       withIntermediateDirectories:YES
                        attributes:nil
                             error:NULL];

   // getcwd(3) is symlink free, so this is the canonical base
   base    = [manager currentDirectoryPath];
   dir     = [base stringByAppendingPathComponent:@"resolving-symlinks-work"];
   target  = [dir stringByAppendingPathComponent:@"target"];
   link    = [dir stringByAppendingPathComponent:@"link"];
   abslink = [dir stringByAppendingPathComponent:@"abslink"];
   chain1  = [dir stringByAppendingPathComponent:@"chain1"];
   chain2  = [dir stringByAppendingPathComponent:@"chain2"];

   [manager createFileAtPath:target
                    contents:[NSData dataWithBytes:"hello"
                                            length:5]
                  attributes:nil];

   // relative target: the failing case
   [manager createSymbolicLinkAtPath:link
                         pathContent:@"target"];

   // absolute target: the working case
   [manager createSymbolicLinkAtPath:abslink
                         pathContent:target];

   // a chain of relative links in the same directory
   [manager createSymbolicLinkAtPath:chain1
                         pathContent:@"chain2"];
   [manager createSymbolicLinkAtPath:chain2
                         pathContent:@"target"];

   test( "relative", link,    target);
   test( "absolute", abslink, target);
   test( "chain",    chain1,  target);
   test( "plain",    target,  target);

   [manager removeItemAtPath:@"resolving-symlinks-work"
                       error:NULL];
   return( 0);
}

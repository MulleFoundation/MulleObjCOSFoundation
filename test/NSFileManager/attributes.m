#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


static BOOL   typeIs( NSDictionary *attributes, NSString *type)
{
   return( [[attributes objectForKey:NSFileType] isEqualToString:type]);
}


int   main( int argc, char *argv[])
{
   NSFileManager   *fileManager;
   NSDictionary    *attributes;
   NSDictionary    *item;

   fileManager = [NSFileManager defaultManager];

   [fileManager removeItemAtPath:@"attributes-work" error:NULL];
   [fileManager createDirectoryAtPath:@"attributes-work"
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:NULL];
   [fileManager createFileAtPath:@"attributes-work/a"
                        contents:[NSData dataWithBytes:"hello" length:5]
                      attributes:nil];
   [fileManager setAttributes:@{ NSFilePosixPermissions: @0644 }
                 ofItemAtPath:@"attributes-work/a"
                        error:NULL];
   [fileManager createSymbolicLinkAtPath:@"attributes-work/link"
                             pathContent:@"a"];
   [fileManager createSymbolicLinkAtPath:@"attributes-work/dangling"
                             pathContent:@"nonexistent"];

   // fileAttributesAtPath:traverseLink:
   attributes = [fileManager fileAttributesAtPath:@"attributes-work/a"
                                     traverseLink:YES];
   show( @"attrs.file.type.regular", typeIs( attributes, NSFileTypeRegular));
   show( @"attrs.file.size", [[attributes objectForKey:NSFileSize] unsignedLongLongValue] == 5);
   show( @"attrs.file.perms", [[attributes objectForKey:NSFilePosixPermissions] unsignedIntValue] == 0644);

   attributes = [fileManager fileAttributesAtPath:@"attributes-work/link"
                                     traverseLink:YES];
   show( @"attrs.link.traverse.regular", typeIs( attributes, NSFileTypeRegular));
   attributes = [fileManager fileAttributesAtPath:@"attributes-work/link"
                                     traverseLink:NO];
   show( @"attrs.link.nottraverse.link", typeIs( attributes, NSFileTypeSymbolicLink));

   // attributesOfItemAtPath:error:
   item = [fileManager attributesOfItemAtPath:@"attributes-work/link"
                                        error:NULL];
   show( @"item.link.link", typeIs( item, NSFileTypeSymbolicLink));
   item = [fileManager attributesOfItemAtPath:@"attributes-work/a"
                                        error:NULL];
   show( @"item.file.regular", typeIs( item, NSFileTypeRegular));
   show( @"item.file.size", [[item objectForKey:NSFileSize] unsignedLongLongValue] == 5);
   show( @"item.none.isnil", [fileManager attributesOfItemAtPath:@"attributes-work/nope" error:NULL] == nil);

   // missing and dangling
   show( @"attrs.none.isnil", [fileManager fileAttributesAtPath:@"attributes-work/nope"
                                                   traverseLink:YES] == nil);
   show( @"attrs.dangling.traverse.isnil", [fileManager fileAttributesAtPath:@"attributes-work/dangling"
                                                                traverseLink:YES] == nil);
   attributes = [fileManager fileAttributesAtPath:@"attributes-work/dangling"
                                     traverseLink:NO];
   show( @"attrs.dangling.nottraverse.link", typeIs( attributes, NSFileTypeSymbolicLink));

   [fileManager removeItemAtPath:@"attributes-work" error:NULL];
   return( 0);
}

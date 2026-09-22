#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>


static void   show( NSString *label, BOOL value)
{
   mulle_printf( "%s=%d\n", [label UTF8String], (int) value);
}


int   main( int argc, char *argv[])
{
   NSFileManager       *fileManager;
   NSDictionary        *attributes;
   NSDictionary        *again;
   NSDictionary        *item;
   unsigned long long  size;
   unsigned long long  freeSize;
   unsigned long long  nodes;
   unsigned long long  freeNodes;

   fileManager = [NSFileManager defaultManager];

   attributes = [fileManager fileSystemAttributesAtPath:@"."];
   show( @"fs.notnil", attributes != nil);

   size      = [[attributes objectForKey:NSFileSystemSize] unsignedLongLongValue];
   freeSize  = [[attributes objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
   nodes     = [[attributes objectForKey:NSFileSystemNodes] unsignedLongLongValue];
   freeNodes = [[attributes objectForKey:NSFileSystemFreeNodes] unsignedLongLongValue];

   show( @"fs.size.positive", size > 0);
   show( @"fs.free.le.size", freeSize <= size);
   show( @"fs.nodes.positive", nodes > 0);
   show( @"fs.freenodes.le.nodes", freeNodes <= nodes);
   show( @"fs.number.present", [attributes objectForKey:NSFileSystemNumber] != nil);

   again = [fileManager attributesOfFileSystemForPath:@"."
                                                error:NULL];
   show( @"fs.error.api.same.size",
         [[again objectForKey:NSFileSystemSize] isEqual:[attributes objectForKey:NSFileSystemSize]]);

   // NSFileSystemNumber of an item is the same filesystem number
   item = [fileManager attributesOfItemAtPath:@"."
                                        error:NULL];
   show( @"item.systemnumber.matches.fs",
         [[item objectForKey:NSFileSystemNumber] isEqual:[attributes objectForKey:NSFileSystemNumber]]);

   show( @"fs.none.isnil", [fileManager fileSystemAttributesAtPath:@"nope/nope/nope"] == nil);
   return( 0);
}

#import <MulleObjCOSFoundation/MulleObjCOSFoundation.h>
#include <stdio.h>


int main( void)
{
   NSFileManager   *manager;
   NSString        *path;
   NSData          *written;
   NSData          *read;
   unsigned char   bytes[] = { 'H', 'e', 'l', 'l', 'o' };

   manager = [NSFileManager defaultManager];
   path    = [[manager currentDirectoryPath] stringByAppendingPathComponent:@"data-read-write.tmp"];

   written = [NSData dataWithBytes:bytes length:sizeof( bytes)];

   if( ! [written writeToFile:path atomically:NO])
   {
      mulle_printf( "FAIL: write\n");
      return( 1);
   }

   read = [NSData dataWithContentsOfFile:path];
   if( ! read)
   {
      mulle_printf( "FAIL: read\n");
      return( 1);
   }

   if( ! [written isEqualToData:read])
   {
      mulle_printf( "FAIL: content mismatch\n");
      return( 1);
   }

   [manager removeFileAtPath:path handler:nil];

   mulle_printf( "OK\n");
   return( 0);
}

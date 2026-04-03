#import "import.h"

int main()
{
   NSMutableDictionary  *dict;
   NSEnumerator         *enumerator;
   id                   key;
   id                   value;
   NSString             *k1;
   NSString             *v1;
   
   dict = [NSMutableDictionary new];
   
   k1 = [@"key1" retain];
   v1 = [@"value1" retain];
   [dict mulleSetRetainedObject:v1 forCopiedKey:k1];
   
   k1 = [@"key2" retain];
   v1 = [@"value2" retain];
   [dict mulleSetRetainedObject:v1 forCopiedKey:k1];
   
   mulle_printf("Starting enumeration...\n");
   
   enumerator = [dict keyEnumerator];
   while( (key = [enumerator nextObject]))
   {
      value = [dict objectForKey:key];
      mulle_printf("Key: %s, Value: %s\n", [key UTF8String], [value UTF8String]);
   }
   
   mulle_printf("Done\n");
   [dict release];
   
   return 0;
}

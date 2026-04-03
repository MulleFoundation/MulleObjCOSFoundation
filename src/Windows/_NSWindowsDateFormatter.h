#import "import.h"

@interface _NSWindowsDateFormatter : NSDateFormatter

- (BOOL) getObjectValue:(id *) obj
              forString:(NSString *) string
                  range:(NSRange *) rangep
                  error:(NSError **) error;

- (NSString *) stringFromDate:(id) date;
- (id) dateFromString:(NSString *) s;

@end


@interface NSDateFormatter( WindowsFuture)

- (size_t) _printTM:(struct tm *) tm
             buffer:(char *) buf
             length:(size_t) len
      formatUTF8String:(char *) c_format
             locale:(NSLocale *) locale;

- (NSDate *) _parseDateWithUTF8String:(char **) string
                        formatUTF8String:(char *) c_format
                               locale:(NSLocale *) locale;

@end

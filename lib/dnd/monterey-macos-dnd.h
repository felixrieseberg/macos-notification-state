#import <Foundation/Foundation.h>

@interface MontereyDND : NSObject
+ (bool)isEnabled;
+ (bool)enabledByAssertion;
+ (bool)enabledBySchedule;
+ (NSString*)getFocusMode;
+ (bool)allowedForBundleId;
+ (NSDictionary*)readJSONData:(NSString*)filePath;
@end

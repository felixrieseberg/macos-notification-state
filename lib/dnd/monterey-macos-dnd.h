#import <Foundation/Foundation.h>

@interface MontereyDND : NSObject
+ (bool)isEnabled;
+ (bool)enabledByAssertion;
+ (bool)enabledBySchedule;
+ (bool)allowedForBundleId;
+ (NSDictionary*)readJSONData:(NSString*)filePath;
@end

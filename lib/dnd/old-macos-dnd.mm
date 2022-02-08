#import <Foundation/Foundation.h>

bool getOldMacOSDND() {
  return [[[[NSUserDefaults alloc]
      initWithSuiteName:@"com.apple.notificationcenterui"]
      objectForKey:@"doNotDisturb"] boolValue];
}
#import <Foundation/Foundation.h>

bool getDoNotDisturb() {
  bool doNotDisturb = [[[[NSUserDefaults alloc] initWithSuiteName:@"com.apple.notificationcenterui"] objectForKey:@"doNotDisturb"] boolValue];

  return doNotDisturb;
}

#import <Foundation/Foundation.h>

bool getDoNotDisturb() {
  bool doNotDisturb;

  if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion < 11) {
    doNotDisturb = [[[[NSUserDefaults alloc] initWithSuiteName:@"com.apple.notificationcenterui"] objectForKey:@"doNotDisturb"] boolValue];
  } else {
    doNotDisturb = [[[[NSUserDefaults alloc] initWithSuiteName:@"com.apple.controlcenter"] objectForKey:@"NSStatusItem Visible DoNotDisturb"] boolValue];
  }
  return doNotDisturb;
}

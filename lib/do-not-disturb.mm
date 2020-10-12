#import <Foundation/Foundation.h>

bool getDoNotDisturb() {
  bool doNotDisturb;
  NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
  bool isBigSur = version.majorVersion == 11 || (version.majorVersion == 10 && version.minorVersion > 15);
  if (!isBigSur) {
    doNotDisturb = [[[[NSUserDefaults alloc] initWithSuiteName:@"com.apple.notificationcenterui"] objectForKey:@"doNotDisturb"] boolValue];
  } else {
    doNotDisturb = [[[[NSUserDefaults alloc] initWithSuiteName:@"com.apple.controlcenter"] objectForKey:@"NSStatusItem Visible DoNotDisturb"] boolValue];
  }
  return doNotDisturb;
}

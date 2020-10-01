#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>

bool getDoNotDisturb() {
  bool doNotDisturb;

  if (floor(NSAppKitVersionNumber) < 11) {
    doNotDisturb = [[[[NSUserDefaults alloc] initWithSuiteName:@"com.apple.notificationcenterui"] objectForKey:@"doNotDisturb"] boolValue];
  } else {
    doNotDisturb = [[[[NSUserDefaults alloc] initWithSuiteName:@"com.apple.controlcenter"] objectForKey:@"NSStatusItem Visible DoNotDisturb"] boolValue];
  }
  return doNotDisturb;
}

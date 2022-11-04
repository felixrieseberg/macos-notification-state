#import "dnd/bigsur-macos-dnd.h"
#import "dnd/monterey-macos-dnd.h"
#import "dnd/old-macos-dnd.h"
#import <Foundation/Foundation.h>

bool getDoNotDisturb() {
  NSOperatingSystemVersion version =
      [[NSProcessInfo processInfo] operatingSystemVersion];
  bool isBigSur = version.majorVersion == 11 ||
                  (version.majorVersion == 10 && version.minorVersion > 15);
  bool isAtLeastMonterey = version.majorVersion >= 12;

  @try {
    if (isBigSur) {
      return getBigSurMacOSDND();
    } else if (isAtLeastMonterey) {
      return [MontereyDND isEnabled];
    } else {
      return getOldMacOSDND();
    }
  } @catch (NSException *error) {
    NSLog(@"Failed to detect DND status: %@", error);
  }
  return false;
}

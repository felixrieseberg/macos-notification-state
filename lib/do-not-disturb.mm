#import "dnd/bigsur-macos-dnd.h"
#import "dnd/monterey-macos-dnd.h"
#import "dnd/old-macos-dnd.h"
#import "macos-version.h"
#import <Foundation/Foundation.h>

bool getDoNotDisturb() {
  auto majorVersion = getOSVersion();
  bool isBigSur = majorVersion == 11;
  bool isMonterey = majorVersion == 12;

  @try {
    if (isBigSur) {
      return getBigSurMacOSDND();
    } else if (isMonterey) {
      return [MontereyDND isEnabled];
    } else if (majorVersion < 11) {
      return getOldMacOSDND();
    }
  } @catch (NSException *error) {
    NSLog(@"Failed to detect DND status: %@", error);
  }
  return false;
}

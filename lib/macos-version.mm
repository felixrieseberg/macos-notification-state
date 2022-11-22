#import <Foundation/Foundation.h>

int getOSVersion() {
  NSOperatingSystemVersion version =
      [[NSProcessInfo processInfo] operatingSystemVersion];
  bool isBigSur = version.majorVersion == 11 ||
                  (version.majorVersion == 10 && version.minorVersion > 15);

  if (isBigSur) {
    return 11;
  }
  return version.majorVersion;
}
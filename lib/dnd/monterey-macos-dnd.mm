#import "monterey-macos-dnd.h"
#import <Foundation/Foundation.h>

@implementation MontereyDND
+ (bool)isEnabled {
  // Focus Preferences: ~/Library/DoNotDisturb/DB/ immediately updates
  // Assertion.json - DND on/off -
  // ModeConfiguration.json - Scheduled config stored
  // ModeConfigurationSecure.json - Contains Apps allowed in DND mode

  // 1. check assertion
  bool isDNDEnabled = [self enabledByAssertion];
  if (!isDNDEnabled) {
    // 2. check schedule config
    isDNDEnabled = [self enabledBySchedule];
  }

  if (isDNDEnabled) {
    // 3 additional check is bundleIdentifier allowed while DND is on
    bool isBundleIdAllowedInDND = [self allowedForBundleId];
    // DND is "off" for current application
    isDNDEnabled = !isBundleIdAllowedInDND;
  }
  return isDNDEnabled;
}

+ (bool)allowedForBundleId {
  NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
  if (bundleIdentifier) {
    NSDictionary *modeConfigSecureDict =
        [self readJSONData:
                  @"~/Library/DoNotDisturb/DB/ModeConfigurationsSecure.json"];
    NSDictionary *allowedApps = [[[[[[modeConfigSecureDict valueForKey:@"data"]
        objectAtIndex:0] valueForKey:@"secureModeConfigurations"]
        valueForKey:@"com.apple.donotdisturb.mode.default"]
        valueForKey:@"secureConfiguration"] valueForKey:@"allowedApplications"];

    if (!allowedApps)
      return false;

    NSDictionary *byBundle = [allowedApps valueForKey:bundleIdentifier];
    if (byBundle) {
      return true;
    }
    // try predicate - for case if bundle is child process
    NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"%@ CONTAINS SELF", bundleIdentifier];
    NSArray *apps =
        [[allowedApps allKeys] filteredArrayUsingPredicate:predicate];
    if ([apps count] > 0) {
      return true;
    }
  }
  return false;
}

+ (bool)enabledByAssertion {
  NSDictionary *assertDict =
      [self readJSONData:@"~/Library/DoNotDisturb/DB/Assertions.json"];

  if (!assertDict) {
    return false;
  }

  NSDictionary *assertionData =
      [[assertDict valueForKey:@"data"] objectAtIndex:0];
  NSArray *storeAssertionRecords =
      [assertionData valueForKey:@"storeAssertionRecords"];
  // has active assertion - DND is ON
  if (storeAssertionRecords) {
    // TODO: can be improved by add compare timestamp of assertion with header
    int size = [storeAssertionRecords count];
    if (size > 0)
      return true;
  }
  return false;
}

+ (NSDictionary *)readJSONData:(NSString *)filePath {
  NSString *fullPath = [filePath stringByExpandingTildeInPath];
  NSError *error = nil;
  NSData *jsonData = [NSData dataWithContentsOfFile:fullPath
                                            options:kNilOptions
                                              error:&error];
  if (error) {
    NSLog(@"Failed to open %s, error %@", fullPath, error);
    return nil;
  }

  NSDictionary *parsedDictionary =
      [NSJSONSerialization JSONObjectWithData:jsonData
                                      options:kNilOptions
                                        error:&error];
  if (error) {
    NSLog(@"Failed to parse dict %s, error %@", fullPath, error);
    return nil;
  }

  return parsedDictionary;
}

+ (bool)enabledBySchedule {
  NSDictionary *modeConfigDict =
      [self readJSONData:@"~/Library/DoNotDisturb/DB/ModeConfigurations.json"];

  bool hasActiveTrigger = false;
  NSArray *triggers = [[[[[[modeConfigDict valueForKey:@"data"] objectAtIndex:0]
      valueForKey:@"modeConfigurations"]
      valueForKey:@"com.apple.donotdisturb.mode.default"]
      valueForKey:@"triggers"] valueForKey:@"triggers"];
  if (triggers) {
    if ([triggers count] == 0) {
      return hasActiveTrigger;
    }
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components =
        [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute)
                    fromDate:now];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSInteger currentMinutes = (hour * 60) + minute;

    for (NSDictionary *item in triggers) {
      NSNumber *enabledSetting = [item valueForKey:@"enabledSetting"];
      if ([enabledSetting intValue] == 2) {
        // If the schedule is enabled, we need to manually determine if we fall
        // in the start / end interval
        NSNumber *startHour = [item valueForKey:@"timePeriodStartTimeHour"];
        NSNumber *endHour = [item valueForKey:@"timePeriodEndTimeHour"];
        NSNumber *startMinutesSetting =
            [item valueForKey:@"timePeriodStartTimeMinute"];
        if (startHour && endHour) {
          NSInteger startMinutes =
              [startHour intValue] * 60 + [startMinutesSetting intValue];
          NSInteger endMinutes = [endHour intValue] * 60;
          // Normal way round, start is before the end
          if (startMinutes < endMinutes) {
            // Start is inclusive, end is exclusive
            if (currentMinutes >= startMinutes && currentMinutes < endMinutes) {
              hasActiveTrigger = true;
            }
          } else if (endMinutes < startMinutes) {
            // The end can also be _after_ the start making the DND interval
            // loop over midnight
            if (currentMinutes >= startMinutes || currentMinutes < endMinutes) {
              hasActiveTrigger = true;
            }
          }
        }
      }
    }
  }
  // not enabled due to schedule
  return hasActiveTrigger;
}

+ (id)alloc {
  [NSException raise:@"Cannot be instantiated"];
  return nil;
}
@end
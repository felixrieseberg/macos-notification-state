#import <Foundation/Foundation.h>

bool getDoNotDisturb() {
  NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
  bool isBigSur = version.majorVersion == 11 || (version.majorVersion == 10 && version.minorVersion > 15);
  bool isMonterey = version.majorVersion == 12;

  if (isBigSur) {
    NSLog(@"MacOS BigSur detected");
    // On big sur we have to read a plist from a plist...
    NSData* dndData = [[[NSUserDefaults alloc] initWithSuiteName:@"com.apple.ncprefs"] dataForKey:@"dnd_prefs"];
    // If there is no DND data let's assume that we aren't in DND
    if (!dndData) return false;

    NSDictionary* dndDict = [NSPropertyListSerialization
            propertyListWithData:dndData
                         options:NSPropertyListImmutable
                          format:nil
                           error:nil];
    // If the dnd data isn't a valid plist, again assume we aren't in DND
    if (!dndDict) return false;
    NSDictionary* userPrefs = [dndDict valueForKey:@"userPref"];
    if (userPrefs) {
      NSNumber* dndEnabled = [userPrefs valueForKey:@"enabled"];
      // If the user pref has it set to enabled
      if ([dndEnabled intValue] == 1) return true;
    }

    NSDictionary* scheduledPrefs = [dndDict valueForKey:@"scheduledTime"];
    if (scheduledPrefs) {
      NSNumber* scheduleEnabled = [scheduledPrefs valueForKey:@"enabled"];
      NSNumber* start = [scheduledPrefs valueForKey:@"start"];
      NSNumber* end = [scheduledPrefs valueForKey:@"end"];
      // If the schedule is enabled, we need to manually determine if we fall in the start / end interval
      if ([scheduleEnabled intValue] == 1 && start && end) {
        NSDate* now = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:now];
        NSInteger hour = [components hour];
        NSInteger minute = [components minute];
        NSInteger current = (hour * 60) + minute;

        NSInteger startInt = [start intValue];
        NSInteger endInt = [end intValue];
        // Normal way round, start is before the end
        if (startInt < endInt) {
          // Start is inclusive, end is exclusive
          if (current >= startInt && current < endInt) return true;
        } else if (endInt < startInt) {
          // The end can also be _after_ the start making the DND interval loop over midnight
          if (current >= startInt) return true;
          if (current < endInt) return true;
        }
      }
    }

    // TODO: Support and check the follow dndDict keys
    // - dndDisplaySleep
    // - dndDisplayLock
    // - dndMirrored

    // Not manually enabled, not enabled due to schedule
    return false;
  } else if (isMonterey) {
    // TODO: add try catch
    NSLog(@"MacOS Monterey detected");
    // there are two places that changed immediately after you change DND stuff
    // Folder: ~/Library/DoNotDisturb/DB/
    // Assertion.json - DND on/off - without scheduled time
    // ModeConfiguration.json - Scheduled config stored here

    NSString* assertionFilePath = [@"~/Library/DoNotDisturb/DB/Assertions.json" stringByExpandingTildeInPath];
    NSError* error = nil;
    NSData* AssertJSONData = [NSData dataWithContentsOfFile:assertionFilePath options:NSDataReadingMappedIfSafe error:&error];
    if (error) {
     NSLog(@"Failed to open assertions, error %@", error);
     return false;
    }

    NSDictionary* assertDict = [NSJSONSerialization
                         JSONObjectWithData:AssertJSONData
                         options:NSJSONReadingAllowFragments
                         error:&error];
    if (error) {
     NSLog(@"Failed to parse assertions, error %@", error);
     return false;
    }

    NSDictionary* assertionData = [[assertDict valueForKey:@"data"] objectAtIndex:0];
    NSArray* storeAssertionRecords = [assertionData valueForKey:@"storeAssertionRecords"];
    // has active assertion - DND is ON
    if (storeAssertionRecords) {
       // TODO: can be improved by add compare timestamp of assertion with header
      int size = [storeAssertionRecords count]; 
      if (size > 0) return true;
    }
    
    // go and try check schedule
    NSString* modeConfigFilePath = [@"~/Library/DoNotDisturb/DB/ModeConfigurations.json" stringByExpandingTildeInPath];
    NSData* ModeConfigJSONData = [NSData dataWithContentsOfFile:modeConfigFilePath options:NSDataReadingMappedIfSafe error:&error];
    if (error) {
     NSLog(@"Failed to open modeConfiguration, error %@", error);
     return false;
    }

    NSDictionary* modeConfigDict = [NSJSONSerialization
                         JSONObjectWithData:ModeConfigJSONData
                         options:kNilOptions
                         error:&error];
    if (error) {
     NSLog(@"Failed to parse modeConfiguration, error %@", error);
     return false;
    }


    bool hasActiveTrigger = false;
    NSArray* triggers = [[[[[[modeConfigDict valueForKey:@"data"] objectAtIndex:0] valueForKey:@"modeConfigurations"] valueForKey:@"com.apple.donotdisturb.mode.default"] valueForKey:@"triggers"] valueForKey:@"triggers"];
    if (triggers) {
      if ([triggers count] == 0) {
        NSLog(@"Triggers are empty");
        return hasActiveTrigger;
      }
      NSDate* now = [NSDate date];
      NSCalendar *calendar = [NSCalendar currentCalendar];
      NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:now];
      NSInteger hour = [components hour];
      NSInteger minute = [components minute];
      NSInteger currentMinutes = (hour * 60) + minute;

      for (NSDictionary *item in triggers) {
        NSNumber* enabledSetting = [item valueForKey:@"enabledSetting"];
        if ([enabledSetting intValue] == 2) {
          // If the schedule is enabled, we need to manually determine if we fall in the start / end interval
          NSNumber* startHour = [item valueForKey:@"timePeriodStartTimeHour"];
          NSNumber* endHour = [item valueForKey:@"timePeriodEndTimeHour"];
          NSNumber* startMinutesSetting = [item valueForKey:@"timePeriodStartTimeMinute"];
          if (startHour && endHour) {
            NSInteger startMinutes = [startHour intValue] * 60 + [startMinutesSetting intValue];
            NSInteger endMinutes = [endHour intValue] * 60;
            NSLog(@"Found enabled trigger: StartMinutes: %ld, EndMinutes: %ld, currentMinutes: %ld", startMinutes, endMinutes, currentMinutes);
            // Normal way round, start is before the end
            if (startMinutes < endMinutes) {
              // Start is inclusive, end is exclusive
              if (currentMinutes >= startMinutes && currentMinutes < endMinutes) {
                hasActiveTrigger = true;
              }
            } else if (endMinutes < startMinutes) {
              // The end can also be _after_ the start making the DND interval loop over midnight
              if (currentMinutes >= startMinutes || currentMinutes < endMinutes) {
                hasActiveTrigger = true;
              }
            }
          }
        }
      }
    }
    // Not manually enabled, not enabled due to schedule
    return hasActiveTrigger;
  } 
  NSLog(@"MacOS prior BigSur(Mohave, Catalina, ...) detected");
  return [[[[NSUserDefaults alloc] initWithSuiteName:@"com.apple.notificationcenterui"] objectForKey:@"doNotDisturb"] boolValue];
}

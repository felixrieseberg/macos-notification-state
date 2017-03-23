#include <ApplicationServices/ApplicationServices.h>
#include "notificationstate-query.h"

int queryUserSessionState() {
  CFDictionaryRef sessionDict = CGSessionCopyCurrentDictionary();
  if (sessionDict == NULL) {
      return -1;
  }

  CFBooleanRef sessionScreenIsLockedRef = (CFBooleanRef)CFDictionaryGetValue(sessionDict, CFSTR("CGSSessionScreenIsLocked"));

  bool sessionScreenIsLocked = sessionScreenIsLockedRef ? CFBooleanGetValue(sessionScreenIsLockedRef) : false;

  CFBooleanRef sessionOnConsoleKeyRef = (CFBooleanRef)CFDictionaryGetValue(sessionDict, CFSTR("kCGSSessionOnConsoleKey"));
  bool sessionOnConsoleKey = sessionOnConsoleKeyRef ? CFBooleanGetValue(sessionOnConsoleKeyRef) : false;

  CFRelease(sessionDict);

  if (sessionScreenIsLocked) {
    return 1;
  } else if (sessionOnConsoleKey) {
    return 2;
  } else {
    return 0;
  }
}

function safeLoad(addonName) {
  try {
    return require("bindings")(addonName);
  } catch (e) {
    console.log(
      `[macos-notification-state] failed to load '${addonName}' addon`,
      e
    );
  }
}
// bindings - do search addon on each call - so load addon once when module loaded instead of each fn call
const notificationState = safeLoad("notificationstate");

/**
 * Returns the status, either 'UNKNOWN_ERROR', 'UNKNOWN', 'SESSION_SCREEN_IS_LOCKED','SESSION_ON_CONSOLE_KEY', or 'DO_NOT_DISTURB'. If DND is enabled, the session state isn't checked.
 *
 * @returns {Promise<string>} USER_NOTIFICATION_STATE
 */
function getNotificationState() {
  const USER_NOTIFICATION_STATE = [
    "UNKNOWN",
    "SESSION_SCREEN_IS_LOCKED",
    "SESSION_ON_CONSOLE_KEY",
    "DO_NOT_DISTURB",
  ];

  return getDoNotDisturb().then((dnd) => {
    if (dnd) return USER_NOTIFICATION_STATE[3];
    const ss = notificationState.getNotificationState();
    if (USER_NOTIFICATION_STATE[ss]) {
      return USER_NOTIFICATION_STATE[ss];
    } else {
      return "UNKNOWN_ERROR";
    }
  });
}

/**
 * Returns the session state
 *
 * @returns {string} sessionState
 */
function getSessionState() {
  const result = notificationState.getNotificationState();

  if (result === -1) {
    throw new Error(
      "Getting session state for macOS encountered unknown error"
    );
  } else if (result === 1) {
    return "SESSION_SCREEN_IS_LOCKED";
  } else if (result === 2) {
    return "SESSION_ON_CONSOLE_KEY";
  } else {
    return "UNKNOWN";
  }
}

let focusCenterOnceTryedToLoad = false;
let focusCenter;
/**
 * Is do not disturb enabled?
 *
 * @returns {Promise<boolean>} isDoNotDisturb
 */
function getDoNotDisturb() {
  return new Promise((resolve, reject) => {
    const dnd = notificationState.getDoNotDisturb();

    if (dnd === -1) {
      // will return if macos > 12
      if (!focusCenterOnceTryedToLoad) {
        focusCenter = safeLoad("focuscenter");
        // try load addon only once to avoid execute redundant logic and errors on each attempt
        focusCenterOnceTryedToLoad = true;
      }
      if (focusCenter && focusCenter.getFocusStatus) {
        focusCenter
          .getFocusStatus()
          .then((isFocused) => resolve(isFocused === 1))
          .catch((e) => reject(e));
      } else {
        reject(new Error("getFocusStatus not supported"));
      }
    } else {
      return resolve(dnd === 1);
    }
  });
}

function withValidation(action) {
  return () => {
    if (process.platform !== "darwin") {
      throw new Error("[macos-notification-state] only works on macOS");
    }
    if (!notificationState) {
      throw new Error(
        "[macos-notification-state] notificationstate addon not loaded"
      );
    }
    return action();
  };
}

module.exports = {
  getDoNotDisturb: withValidation(getDoNotDisturb),
  getNotificationState: withValidation(getNotificationState),
  getSessionState: withValidation(getSessionState),
};

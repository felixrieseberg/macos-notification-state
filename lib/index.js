const notificationState = require("bindings")("notificationstate");

/**
 * Returns the status, either 'UNKNOWN_ERROR', 'UNKNOWN', 'SESSION_SCREEN_IS_LOCKED','SESSION_ON_CONSOLE_KEY', or 'DO_NOT_DISTURB'. If DND is enabled, the session state isn't checked.
 *
 * @returns {string} USER_NOTIFICATION_STATE
 */
function getNotificationState() {
  if (process.platform !== "darwin") {
    throw new Error("macos-notification-state only works on macOS");
  }

  const USER_NOTIFICATION_STATE = [
    "UNKNOWN",
    "SESSION_SCREEN_IS_LOCKED",
    "SESSION_ON_CONSOLE_KEY",
    "DO_NOT_DISTURB",
  ];

  const dnd = getDoNotDisturb();
  if (dnd) return USER_NOTIFICATION_STATE[3];

  const ss = notificationState.getNotificationState();
  if (USER_NOTIFICATION_STATE[ss]) {
    return USER_NOTIFICATION_STATE[ss];
  } else {
    return "UNKNOWN_ERROR";
  }
}

/**
 * Returns the session state
 *
 * @returns {string} sessionState
 */
function getSessionState() {
  if (process.platform !== "darwin") {
    throw new Error("macos-notification-state only works on macOS");
  }

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

/**
 * Is do not disturb enabled?
 *
 * @returns {boolean} isDoNotDisturb
 */
function getDoNotDisturb() {
  if (process.platform !== "darwin") {
    throw new Error("macos-notification-state only works on macOS");
  }
  return new Promise((resolve, reject) => {
    const dnd = notificationState.getDoNotDisturb();

    if (dnd === -1) {
      // will return if macos > 12
      const focusCenter = require("bindings")("focuscenter");
      if (!!focusCenter.getFocusStatus) {
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

module.exports = {
  getDoNotDisturb,
  getNotificationState,
  getSessionState,
};

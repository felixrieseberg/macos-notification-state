type SessionState = 'SESSION_SCREEN_IS_LOCKED' | 'SESSION_ON_CONSOLE_KEY' | 'UNKNOWN';
type DoNotDisturbState = 'DO_NOT_DISTURB';

declare module 'macos-notification-state' {
  export function getNotificationState(): 'UNKNOWN_ERROR' | SessionState | DoNotDisturbState;
  export function getSessionState():  SessionState;
  export function getDoNotDisturb(): boolean;
}

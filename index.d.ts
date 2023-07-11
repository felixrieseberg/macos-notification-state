declare module "macos-notification-state" {
  export function getNotificationState(): Promise<
    "UNKNOWN_ERROR" | SessionState | "DO_NOT_DISTURB"
  >;
  export function getSessionState(): SessionState;
  export function getDoNotDisturb(): Promise<boolean>;
  export type SessionState =
    | "SESSION_SCREEN_IS_LOCKED"
    | "SESSION_ON_CONSOLE_KEY"
    | "UNKNOWN";
}

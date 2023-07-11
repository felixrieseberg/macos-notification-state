# 3.0.0
- Support macOS 13 - use FocusStatus API to detect Focus mode active or not
(its internally compute final state - include checking for personal focus schedule and allowed apps)
- details here: https://developer.apple.com/documentation/usernotifications/handling_communication_notifications_and_focus_status_updates

Changed API: getDoNotDisturb now return Promise<boolean>

# 2.0.2
- Support macOS 13, fixing a "if version === 12" check

# 2.0.1
- Fix broken preinstall on Windows

# 2.0.0

- Major overhaul to support macOS Monterey
- Now requires 11.0 SDK
- Otherwise no API changes
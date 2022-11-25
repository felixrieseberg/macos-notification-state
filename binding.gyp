{
  "targets": [
    {
      "target_name": "notificationstate",
      "sources": [],
      "conditions": [
        ['OS=="mac"', {
          "sources": [
            "lib/notificationstate.cc",
            "lib/notificationstate-query.cc", 
            "lib/do-not-disturb.mm", 
            "lib/macos-version.mm",
            "lib/dnd/old-macos-dnd.mm", 
            "lib/dnd/bigsur-macos-dnd.mm", 
            "lib/dnd/monterey-macos-dnd.mm"
          ],
          "xcode_settings": {
              "OTHER_CPLUSPLUSFLAGS": ["-std=c++17", "-stdlib=libc++", "-mmacosx-version-min=10.7"],
              "OTHER_LDFLAGS": ["-framework CoreFoundation -framework CoreGraphics"]
          }
        }],
      ]
    },
    {
      "target_name": "focuscenter",
      "sources": [],
      "conditions": [
        ['OS=="mac"', {
          "sources": ["lib/focus-center.mm"],
          'include_dirs' : [ "<!@(node -p \"require('node-addon-api').include\")" ],
          'defines': [ 'NAPI_DISABLE_CPP_EXCEPTIONS' ],
          "xcode_settings": {
              "OTHER_CPLUSPLUSFLAGS": ["-std=c++17", "-stdlib=libc++", "-mmacosx-version-min=10.7"],
              "OTHER_LDFLAGS": ["-framework Foundation -weak_framework Intents"]
          }
        }],
      ]
    }
  ]
}

{
  "targets": [
    {
      "target_name": "notificationstate",
      "sources": [ "lib/notificationstate.cc" ],
      "conditions": [
        ['OS=="mac"', {
          "sources": [
            "lib/notificationstate-query.cc", 
            "lib/do-not-disturb.mm", 
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
    }
  ]
}

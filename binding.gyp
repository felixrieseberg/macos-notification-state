{
  "targets": [
    {
      "target_name": "notificationstate",
      "sources": [ "lib/notificationstate.cc" ],
      "conditions": [
        ['OS=="mac"', {
          "sources": ["lib/notificationstate-query.cc", "lib/do-not-disturb.mm"],
          "xcode_settings": {
              "OTHER_CPLUSPLUSFLAGS": ["-std=c++11", "-stdlib=libc++", "-mmacosx-version-min=10.7"],
              "OTHER_LDFLAGS": ["-framework CoreFoundation -framework CoreGraphics"]
          }
        }],
      ]
    }
  ]
}

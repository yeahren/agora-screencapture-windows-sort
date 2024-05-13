{
  "targets": [
    {
      "target_name": "SortWindowsAddon",
      "cflags!": [ "-fno-exceptions" ],
      "cflags_cc!": [ "-fno-exceptions" ],
      "include_dirs": ["<!@(node -p \"require('node-addon-api').include\")"],
      "dependencies": [ "<!@(node -p \"require('node-addon-api').gyp\")" ],
      'defines': [ 
        'NAPI_DISABLE_CPP_EXCEPTIONS' 
      ],
      'conditions':[
        [
          'OS=="mac"',
          {
            'sources':["src/main_mac.mm"],
            "cflags!": [ "-framework Cocoa" ],
            "cflags_cc!": [ "-framework Cocoa", "-pthread", "-Wl,--no-as-needed", "-ldl" ],
            "cflags_cc": [ "-Wno-ignored-qualifiers","-framework Cocoa" ],
            "cflags": [ "-framework Cocoa"],
            'link_settings': {
        'libraries': [
          '$(SDKROOT)/System/Library/Frameworks/Cocoa.framework',
        ],
      },
          },
        ],[
          'OS=="win"',
          {
            'sources':["src/main_win.cpp"]
          }
        ]
      ]
    }
  ]
}
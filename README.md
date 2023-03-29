# Cocoapods SwiftUI Previews workaround for static linking


This repository contains a workaround to make SwiftUI Previews work correctly in Cocoapods when using the configuration `use_modular_headers!`

This solution compiles the targets that contain SwiftUI Preview code dynamically and keeps the rest of them static.

It is intended to be used locally while in production to continue using static linking in all the pods; if you want to test the production configuration, you can run:
`CI=true pod install`

The code that does all the magic can be found in [swiftui.rb](https://github.com/omarzl/CocoapodsSwiftUIPreviews/blob/main/swiftui.rb)

Tested in Xcode 14.2 and CocoaPods 1.11.3

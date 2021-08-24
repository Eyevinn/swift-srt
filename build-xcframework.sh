#!/bin/bash

# Build for iOS Simulator on Intel Macs
xcodebuild archive -scheme "swift-srt (iOS Simulator)" -archivePath ./build/swift-srt-iphonesimulator.xcarchive -sdk iphonesimulator -arch x86_64 SKIP_INSTALL=NO

# Build for iOS and iPadOS
xcodebuild archive -scheme "swift-srt (iOS/iPadOS)" -archivePath ./build/swift-srt-iphoneos.xcarchive -sdk iphoneos SKIP_INSTALL=NO

# Build for macOS (Intel)
xcodebuild archive -scheme "swift-srt (macOS Intel)" -archivePath ./build/swift-srt-macosintel.xcarchive -sdk macosx SKIP_INSTALL=NO

# Create xcframework
xcodebuild -create-xcframework \
-framework ./build/swift-srt-iphoneos.xcarchive/Products/Library/Frameworks/swift_srt.framework \
-framework ./build/swift-srt-iphonesimulator.xcarchive/Products/Library/Frameworks/swift_srt.framework \
-framework ./build/swift-srt-macosintel.xcarchive/Products/Library/Frameworks/swift_srt.framework \
-output ./swift-srt.xcframework

# Clean up
rm -rf ./build
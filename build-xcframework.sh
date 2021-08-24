#!/bin/bash

BASEDIR=$(dirname "$0")

# Build for iOS Simulator on Intel Macs
xcodebuild archive -scheme "swift-srt (iOS Simulator)" -archivePath $BASEDIR/swift-srt-iphonesimulator.xcarchive -sdk iphonesimulator -arch x86_64 SKIP_INSTALL=NO

# Build for iOS and iPadOS
xcodebuild archive -scheme "swift-srt (iOS/iPadOS)" -archivePath $BASEDIR/swift-srt-iphoneos.xcarchive -sdk iphoneos SKIP_INSTALL=NO

# Build for macOS (Intel)
xcodebuild archive -scheme "swift-srt (macOS Intel)" -archivePath $BASEDIR/swift-srt-macosintel.xcarchive -sdk macosx SKIP_INSTALL=NO

# Create xcframework
xcodebuild -create-xcframework \
-framework $BASEDIR/swift-srt-iphoneos.xcarchive/Products/Library/Frameworks/swift_srt.framework \
-framework $BASEDIR/swift-srt-iphonesimulator.xcarchive/Products/Library/Frameworks/swift_srt.framework \
-framework $BASEDIR/swift-srt-macosintel.xcarchive/Products/Library/Frameworks/swift_srt.framework \
-output $BASEDIR/swift-srt.xcframework

# Clean up
rm -rf $BASEDIR/swift-srt-iphoneos.xcarchive
rm -rf $BASEDIR/swift-srt-iphonesimulator.xcarchive
rm -rf $BASEDIR/swift-srt-macosintel.xcarchive

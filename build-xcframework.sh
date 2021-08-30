#!/bin/bash

BUILD_DIR=$(dirname "$0")/Frameworks
OUTPUT_DIR=$( mktemp -d )
set -x

# Build for iOS Simulator on Intel Macs
xcodebuild archive -scheme "swift-srt (iOS Simulator)" -archivePath $OUTPUT_DIR/swift-srt-iphonesimulator.xcarchive -sdk iphonesimulator -arch x86_64 SKIP_INSTALL=NO ENABLE_BITCODE=NO | xcpretty

# Build for iOS and iPadOS
xcodebuild archive -scheme "swift-srt (iOS/iPadOS)" -archivePath $OUTPUT_DIR/swift-srt-iphoneos.xcarchive -sdk iphoneos SKIP_INSTALL=NO ENABLE_BITCODE=NO | xcpretty

# Build for macOS (Intel)
xcodebuild archive -scheme "swift-srt (macOS Intel)" -archivePath $OUTPUT_DIR/swift-srt-macosintel.xcarchive -sdk macosx SKIP_INSTALL=NO ENABLE_BITCODE=NO | xcpretty

# Remove old xcframework
rm -rf $BUILD_DIR/SwiftSRT.xcframework

# Create xcframework
xcodebuild -create-xcframework \
-framework $OUTPUT_DIR/swift-srt-iphoneos.xcarchive/Products/Library/Frameworks/SwiftSRT.framework \
-framework $OUTPUT_DIR/swift-srt-iphonesimulator.xcarchive/Products/Library/Frameworks/SwiftSRT.framework \
-framework $OUTPUT_DIR/swift-srt-macosintel.xcarchive/Products/Library/Frameworks/SwiftSRT.framework \
-output $BUILD_DIR/SwiftSRT.xcframework | xcpretty

# Clean up
rm -rf $OUTPUT_DIR

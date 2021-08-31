#!/bin/bash

BUILD_DIR=$(dirname "$0")/Frameworks
OUTPUT_DIR=$( mktemp -d )
set -x

# Build for iOS and iPadOS
xcrun xcodebuild build -project swift-srt.xcodeproj -configuration Release BUILD_LIBRARY_FOR_DISTRIBUTION=YES -scheme "swift-srt (iOS/iPadOS)" -destination 'generic/platform=iOS' -derivedDataPath "${OUTPUT_DIR}"

# Build for iOS Simulator
xcrun xcodebuild build -project swift-srt.xcodeproj -configuration Release BUILD_LIBRARY_FOR_DISTRIBUTION=YES -scheme "swift-srt (iOS Simulator)" -destination 'generic/platform=iOS Simulator' -derivedDataPath "${OUTPUT_DIR}"

# Build for macOS
xcrun xcodebuild build -project swift-srt.xcodeproj -configuration Release BUILD_LIBRARY_FOR_DISTRIBUTION=YES -scheme "swift-srt (macOS)" -destination 'generic/platform=macOS' -derivedDataPath "${OUTPUT_DIR}"

# Remove old xcframework
rm -rf $BUILD_DIR/SwiftSRT.xcframework

# Create xcframework
xcodebuild -create-xcframework \
-framework "${OUTPUT_DIR}/Build/Products/Release-iphoneos/SwiftSRT.framework" \
-framework "${OUTPUT_DIR}/Build/Products/Release-iphonesimulator/SwiftSRT.framework" \
-framework "${OUTPUT_DIR}/Build/Products/Release/SwiftSRT.framework" \
-output "${BUILD_DIR}/SwiftSRT.xcframework"

# Clean up
rm -rf $OUTPUT_DIR

#!/bin/bash
set -e

# Root directory of the project
ROOT_DIR="$(pwd)"
LIB_DIR="${ROOT_DIR}/Libraries"
IOS_SCHEME="SwiftyZeroMQ-iOS"
MACOS_SCHEME="SwiftyZeroMQ-macOS"

# Archives output paths
DEVICE_ARCHIVE="${ROOT_DIR}/SwiftyZeroMQ-iOS-device.xcarchive"
SIMULATOR_ARCHIVE="${ROOT_DIR}/SwiftyZeroMQ-iOS-simulator.xcarchive"
MACOS_ARCHIVE="${ROOT_DIR}/SwiftyZeroMQ-macos-macosx.xcarchive"

# Deployment target
DEPLOYMENT_TARGET="12.0"

echo "=== Archiving iOS Device (arm64) ==="
xcodebuild archive \
  -project "${ROOT_DIR}/SwiftyZeroMQ.xcodeproj" \
  -scheme "${IOS_SCHEME}" \
  -sdk iphoneos \
  -archivePath "${DEVICE_ARCHIVE}" \
  IPHONEOS_DEPLOYMENT_TARGET="${DEPLOYMENT_TARGET}" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  ARCHS="arm64" \
  OTHER_LDFLAGS="-L\"${LIB_DIR}\" -lzmq-ios"

echo "=== Archiving iOS Simulator (x86_64 + arm64) ==="
xcodebuild archive \
  -project "${ROOT_DIR}/SwiftyZeroMQ.xcodeproj" \
  -scheme "${IOS_SCHEME}" \
  -sdk iphonesimulator \
  -archivePath "${SIMULATOR_ARCHIVE}" \
  IPHONEOS_DEPLOYMENT_TARGET="${DEPLOYMENT_TARGET}" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  ARCHS="x86_64 arm64" \
  SWIFT_OPTIMIZATION_LEVEL="-Onone" \
  OTHER_LDFLAGS="-L\"${LIB_DIR}\" -lzmq-ios-simulator"

echo "=== Archiving macOS (universal: x86_64 + arm64) ==="
xcodebuild archive \
  -scheme "${MACOS_SCHEME}" \
  -sdk macosx \
  -archivePath "${MACOS_ARCHIVE}" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo "=== Creating XCFramework ==="
xcodebuild -create-xcframework \
  -framework "${SIMULATOR_ARCHIVE}/Products/Library/Frameworks/SwiftyZeroMQ.framework" \
  -framework "${DEVICE_ARCHIVE}/Products/Library/Frameworks/SwiftyZeroMQ.framework" \
  -framework "${MACOS_ARCHIVE}/Products/Library/Frameworks/SwiftyZeroMQ.framework" \
  -output "${ROOT_DIR}/SwiftyZeroMQ.xcframework"

echo "✅ XCFramework built successfully: ${ROOT_DIR}/SwiftyZeroMQ.xcframework"


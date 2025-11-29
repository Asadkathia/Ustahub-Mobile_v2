#!/bin/sh

# Xcode Cloud post-clone script for Flutter iOS builds
# This script runs after the repository is cloned and before the build starts

set -e

echo "🚀 Starting Xcode Cloud post-clone script..."

# Check if Flutter is already in PATH
if ! command -v flutter &> /dev/null; then
  echo "📦 Flutter not found in PATH, installing..."
  FLUTTER_VERSION="stable"
  FLUTTER_INSTALL_DIR="$HOME/flutter"
  
  if [ ! -d "$FLUTTER_INSTALL_DIR" ]; then
    git clone https://github.com/flutter/flutter.git -b $FLUTTER_VERSION $FLUTTER_INSTALL_DIR
  fi
  
  export PATH="$FLUTTER_INSTALL_DIR/bin:$PATH"
else
  echo "✅ Flutter found in PATH"
fi

# Verify Flutter installation
echo "🔍 Verifying Flutter installation..."
flutter --version

# Enable Flutter for iOS
echo "📱 Precaching Flutter iOS artifacts..."
flutter precache --ios

# Navigate to project root (script runs from project root)
PROJECT_ROOT="$(pwd)"
echo "📂 Project root: $PROJECT_ROOT"

# Get Flutter dependencies
echo "📚 Getting Flutter dependencies..."
flutter pub get

# Ensure Generated.xcconfig exists
echo "🔧 Verifying Flutter configuration files..."
if [ ! -f "ios/Flutter/Generated.xcconfig" ]; then
  echo "⚠️  Generated.xcconfig not found, generating..."
  cd ios
  flutter pub get
  cd ..
fi

# Verify Generated.xcconfig exists before proceeding
if [ ! -f "ios/Flutter/Generated.xcconfig" ]; then
  echo "❌ ERROR: Generated.xcconfig still not found after flutter pub get"
  exit 1
fi

echo "✅ Generated.xcconfig found"

# Install CocoaPods dependencies
echo "🍫 Installing CocoaPods dependencies..."
cd ios

# Ensure Podfile.lock exists or create it
if [ ! -f "Podfile.lock" ]; then
  echo "⚠️  Podfile.lock not found, will be created during pod install"
fi

pod install --repo-update

# Verify Pods directory exists
if [ ! -d "Pods" ]; then
  echo "❌ ERROR: Pods directory not created"
  exit 1
fi

# Verify required file lists exist
REQUIRED_FILES=(
  "Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"
  "Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-input-files.xcfilelist"
  "Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-output-files.xcfilelist"
  "Pods/Target Support Files/Pods-Runner/Pods-Runner-resources-Release-input-files.xcfilelist"
  "Pods/Target Support Files/Pods-Runner/Pods-Runner-resources-Release-output-files.xcfilelist"
)

echo "🔍 Verifying CocoaPods file lists..."
for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "⚠️  Warning: $file not found"
  else
    echo "✅ Found: $file"
  fi
done

cd ..

echo "✅ Post-clone script completed successfully!"


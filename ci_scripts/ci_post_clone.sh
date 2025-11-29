#!/bin/sh

# Xcode Cloud post-clone script for Flutter iOS builds
# This script runs after the repository is cloned and before the build starts
# Last updated: 2025-11-30

set -e

echo "=========================================="
echo "🚀 Xcode Cloud Post-Clone Script Started"
echo "=========================================="

# Get the absolute path to the project root
# In Xcode Cloud, the script runs from the repository root
PROJECT_ROOT="$(pwd)"
echo "📂 Project root: $PROJECT_ROOT"
echo "📂 Current directory: $(pwd)"
echo "📂 Listing root directory:"
ls -la | head -10

# Check if Flutter is already in PATH
if ! command -v flutter &> /dev/null; then
  echo "📦 Flutter not found in PATH, installing..."
  FLUTTER_VERSION="stable"
  FLUTTER_INSTALL_DIR="$HOME/flutter"
  
  if [ ! -d "$FLUTTER_INSTALL_DIR" ]; then
    echo "📥 Cloning Flutter repository..."
    git clone https://github.com/flutter/flutter.git -b $FLUTTER_VERSION $FLUTTER_INSTALL_DIR
  else
    echo "✅ Flutter directory exists, updating..."
    cd $FLUTTER_INSTALL_DIR
    git pull
    cd "$PROJECT_ROOT"
  fi
  
  export PATH="$FLUTTER_INSTALL_DIR/bin:$PATH"
else
  echo "✅ Flutter found in PATH"
fi

# Verify Flutter installation
echo "🔍 Verifying Flutter installation..."
flutter --version
echo ""

# Enable Flutter for iOS
echo "📱 Precaching Flutter iOS artifacts..."
flutter precache --ios
echo ""

# Get Flutter dependencies
echo "📚 Getting Flutter dependencies..."
flutter pub get
echo ""

# Verify we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
  echo "❌ ERROR: pubspec.yaml not found. Current directory: $(pwd)"
  exit 1
fi

# Ensure Flutter directory exists
if [ ! -d "ios/Flutter" ]; then
  echo "📁 Creating ios/Flutter directory..."
  mkdir -p ios/Flutter
fi

# Force generation of Generated.xcconfig
echo "🔧 Generating Flutter configuration files..."
cd ios
flutter pub get
cd "$PROJECT_ROOT"

# Verify Generated.xcconfig exists
if [ ! -f "ios/Flutter/Generated.xcconfig" ]; then
  echo "❌ ERROR: Generated.xcconfig still not found after flutter pub get"
  echo "📂 Checking ios/Flutter directory:"
  ls -la ios/Flutter/ || echo "Directory does not exist"
  echo "📂 Checking ios directory:"
  ls -la ios/ | head -10
  exit 1
fi

echo "✅ Generated.xcconfig found at: ios/Flutter/Generated.xcconfig"
echo "📄 Generated.xcconfig contents (first 5 lines):"
head -5 ios/Flutter/Generated.xcconfig || echo "Could not read file"
echo ""

# Install CocoaPods dependencies
echo "🍫 Installing CocoaPods dependencies..."
cd ios

# Verify Podfile exists
if [ ! -f "Podfile" ]; then
  echo "❌ ERROR: Podfile not found in ios directory"
  exit 1
fi

echo "📄 Podfile found"
echo ""

# Run pod install
echo "🔨 Running pod install..."
pod install --repo-update

# Verify Pods directory exists
if [ ! -d "Pods" ]; then
  echo "❌ ERROR: Pods directory not created after pod install"
  echo "📂 Contents of ios directory:"
  ls -la
  exit 1
fi

echo "✅ Pods directory created"
echo ""

# Verify required file lists exist
REQUIRED_FILES=(
  "Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"
  "Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-input-files.xcfilelist"
  "Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-output-files.xcfilelist"
  "Pods/Target Support Files/Pods-Runner/Pods-Runner-resources-Release-input-files.xcfilelist"
  "Pods/Target Support Files/Pods-Runner/Pods-Runner-resources-Release-output-files.xcfilelist"
)

echo "🔍 Verifying CocoaPods file lists..."
ALL_FILES_EXIST=true
for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "❌ ERROR: Required file not found: $file"
    ALL_FILES_EXIST=false
  else
    echo "✅ Found: $file"
  fi
done

if [ "$ALL_FILES_EXIST" = false ]; then
  echo ""
  echo "⚠️  Some required files are missing. Listing Pods directory structure:"
  find "Pods/Target Support Files" -type f 2>/dev/null | head -20 || echo "Could not list Pods directory"
  echo ""
  echo "⚠️  Continuing anyway - files may be generated during build..."
fi

cd "$PROJECT_ROOT"

echo ""
echo "=========================================="
echo "✅ Post-clone script completed successfully!"
echo "=========================================="


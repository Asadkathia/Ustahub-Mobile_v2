#!/bin/bash

# Xcode Cloud pre-xcodebuild script for Flutter iOS builds
# This script runs right before xcodebuild executes
# Last updated: 2025-11-30
# Location: ios/ci_scripts/ci_pre_xcodebuild.sh

set -euo pipefail

echo "=========================================="
echo "🔨 Xcode Cloud Pre-Xcodebuild Script Started"
echo "=========================================="

# Navigate to repository root (script is in ios/ci_scripts/)
# Use CI_PRIMARY_REPOSITORY_PATH if available, otherwise navigate from script location
if [ -n "$CI_PRIMARY_REPOSITORY_PATH" ]; then
  PROJECT_ROOT="$CI_PRIMARY_REPOSITORY_PATH"
  cd "$PROJECT_ROOT"
else
  cd "$(dirname "$0")/../.."
  PROJECT_ROOT="$(pwd)"
fi

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

# Detect and export FLUTTER_ROOT for xcodebuild
if [ -z "${FLUTTER_ROOT:-}" ]; then
  FLUTTER_ROOT=$(flutter --version --machine 2>/dev/null | grep -o '"flutterRoot":"[^"]*' | cut -d'"' -f4 || echo "")
  if [ -z "$FLUTTER_ROOT" ]; then
    # Fallback: try to find Flutter in common locations
    if [ -d "$HOME/flutter" ]; then
      FLUTTER_ROOT="$HOME/flutter"
    elif command -v flutter &> /dev/null; then
      FLUTTER_BIN=$(which flutter)
      FLUTTER_ROOT=$(dirname "$(dirname "$FLUTTER_BIN")")
    fi
  fi
fi

if [ -n "$FLUTTER_ROOT" ]; then
  export FLUTTER_ROOT
  echo "✅ FLUTTER_ROOT set to: $FLUTTER_ROOT"
else
  echo "⚠️  WARNING: Could not determine FLUTTER_ROOT"
fi

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

# Force generation of Generated.xcconfig with FLUTTER_ROOT set
echo "🔧 Generating Flutter configuration files..."
if [ -n "$FLUTTER_ROOT" ]; then
  export FLUTTER_ROOT
fi
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

# Update Generated.xcconfig with correct FLUTTER_ROOT if needed
if [ -n "${FLUTTER_ROOT:-}" ]; then
  echo "🔧 Updating Generated.xcconfig with FLUTTER_ROOT..."
  echo "   Current FLUTTER_ROOT: $FLUTTER_ROOT"
  
  # Create a temporary file with updated FLUTTER_ROOT
  TEMP_CONFIG="/tmp/Generated.xcconfig.tmp"
  if grep -q "^FLUTTER_ROOT=" ios/Flutter/Generated.xcconfig 2>/dev/null; then
    # Update existing FLUTTER_ROOT line
    if sed "s|^FLUTTER_ROOT=.*|FLUTTER_ROOT=$FLUTTER_ROOT|" ios/Flutter/Generated.xcconfig > "$TEMP_CONFIG" 2>/dev/null; then
      mv "$TEMP_CONFIG" ios/Flutter/Generated.xcconfig
      echo "   ✅ Updated FLUTTER_ROOT in Generated.xcconfig"
    else
      echo "   ⚠️  WARNING: Failed to update FLUTTER_ROOT using sed"
      rm -f "$TEMP_CONFIG"
    fi
  else
    # Add FLUTTER_ROOT at the beginning
    {
      echo "FLUTTER_ROOT=$FLUTTER_ROOT"
      cat ios/Flutter/Generated.xcconfig
    } > "$TEMP_CONFIG" 2>/dev/null && mv "$TEMP_CONFIG" ios/Flutter/Generated.xcconfig && echo "   ✅ Added FLUTTER_ROOT to Generated.xcconfig" || echo "   ⚠️  WARNING: Failed to add FLUTTER_ROOT"
    rm -f "$TEMP_CONFIG"
  fi
fi

echo "✅ Generated.xcconfig found at: ios/Flutter/Generated.xcconfig"
echo "📄 Generated.xcconfig full contents:"
cat ios/Flutter/Generated.xcconfig || echo "Could not read file"
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

# Run pod install with retry logic for network issues
echo "🔨 Running pod install..."
MAX_RETRIES=3
RETRY_COUNT=0
POD_INSTALL_SUCCESS=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if pod install --repo-update; then
    POD_INSTALL_SUCCESS=true
    break
  else
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
      echo "⚠️  pod install failed (attempt $RETRY_COUNT/$MAX_RETRIES), retrying in 10 seconds..."
      sleep 10
    else
      echo "❌ pod install failed after $MAX_RETRIES attempts"
      echo "⚠️  This might be due to network issues with external dependencies"
      echo "⚠️  Attempting to continue anyway - some pods may be missing..."
    fi
  fi
done

# Verify Pods directory exists
if [ ! -d "Pods" ]; then
  echo "❌ ERROR: Pods directory not created after pod install"
  echo "📂 Contents of ios directory:"
  ls -la
  exit 1
fi

echo "✅ Pods directory created"
echo ""

# Verify required file lists exist (using /bin/sh compatible approach)
echo "🔍 Verifying CocoaPods file lists..."
ALL_FILES_EXIST=true

check_file() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "⚠️  Required file not found: $file"
    ALL_FILES_EXIST=false
  else
    echo "✅ Found: $file"
  fi
}

check_file "Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"
check_file "Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-input-files.xcfilelist"
check_file "Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-output-files.xcfilelist"
check_file "Pods/Target Support Files/Pods-Runner/Pods-Runner-resources-Release-input-files.xcfilelist"
check_file "Pods/Target Support Files/Pods-Runner/Pods-Runner-resources-Release-output-files.xcfilelist"

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
echo "✅ Pre-Xcodebuild script completed successfully!"
echo "=========================================="
echo ""
echo "📝 Final configuration:"
echo "   FLUTTER_ROOT=${FLUTTER_ROOT:-<not set>}"
echo "   PROJECT_ROOT=$PROJECT_ROOT"
if [ -f "ios/Flutter/Generated.xcconfig" ]; then
  echo "   Generated.xcconfig FLUTTER_ROOT:"
  grep "^FLUTTER_ROOT=" ios/Flutter/Generated.xcconfig 2>/dev/null || echo "     (not found in file)"
fi
echo ""

#!/bin/bash
set -e

BUILD_ID=$1
echo "Preparing build folder: $BUILD_ID"

BUILD_DIR="app"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# If package.json missing, create minimal project
if [ ! -f package.json ]; then
  echo "package.json missing — generating minimal capacitor project..."
  npm init -y
fi

# Install Capacitor core & CLI
npm install @capacitor/core @capacitor/cli

# Add Android platform if missing
if [ ! -d "android" ]; then
  echo "Adding Android platform..."
  npx cap add android
fi

# Copy uploaded files
SRC_DIR="../builds/$BUILD_ID"
if [ -d "$SRC_DIR" ]; then
  cp -r $SRC_DIR/* .
fi

# Sync Capacitor with Android
npx cap sync android

echo "Capacitor project ready for Android build"

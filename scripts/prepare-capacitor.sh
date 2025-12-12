#!/bin/bash
set -e

BUILD_ID=$1
echo "Preparing build folder: $BUILD_ID"

BUILD_DIR="app"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Initialize package.json if missing
if [ ! -f package.json ]; then
  echo "package.json missing — initializing project..."
  npm init -y
fi

# Install all Capacitor + TS dependencies first
npm install @capacitor/core @capacitor/cli @capacitor/android typescript ts-node @types/node

# If capacitor.config.ts exists, convert to JSON safely
if [ -f "../builds/$BUILD_ID/capacitor.config.ts" ]; then
  echo "Converting capacitor.config.ts to capacitor.config.json"

  cp "../builds/$BUILD_ID/capacitor.config.ts" .

  cat > convert-config.js <<EOL
const { register } = require('ts-node');
register({ compilerOptions: { module: "CommonJS" } });
const fs = require('fs');
const config = require('./capacitor.config.ts').default;
fs.writeFileSync('capacitor.config.json', JSON.stringify(config, null, 2));
console.log('capacitor.config.json created from TS config');
EOL

  node convert-config.js
  rm convert-config.js
fi

# If capacitor.config.json missing, create minimal config
if [ ! -f "capacitor.config.json" ]; then
  echo "capacitor.config.json missing — generating minimal config..."
  cat > capacitor.config.json <<EOL
{
  "appId": "com.example.app",
  "appName": "MyApp",
  "webDir": "www",
  "bundledWebRuntime": false
}
EOL
fi

# Read webDir from capacitor.config.json
WEB_DIR=$(node -p "require('./capacitor.config.json').webDir")
mkdir -p "$WEB_DIR"

# Copy web files (HTML/CSS/JS) into webDir
echo "Copying web files into $WEB_DIR"
cp ../builds/$BUILD_ID/* "$WEB_DIR" 2>/dev/null || true
# Remove the TS config if copied
rm -f "$WEB_DIR/capacitor.config.ts"

# Add Android platform if missing
if [ ! -d "android" ]; then
  echo "Adding Android platform..."
  npx cap add android
fi

# Sync Capacitor
npx cap sync android

echo "Capacitor project ready for Android build"

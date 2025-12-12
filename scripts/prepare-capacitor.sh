#!/bin/bash
set -e

BUILD_ID=$1
echo "Preparing build folder: $BUILD_ID"

BUILD_DIR="app"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Copy uploaded files
SRC_DIR="../builds/$BUILD_ID"
if [ -d "$SRC_DIR" ]; then
  cp -r $SRC_DIR/* .
fi

# If capacitor.config.ts exists, convert to JSON safely
if [ -f "capacitor.config.ts" ]; then
  echo "Converting capacitor.config.ts to capacitor.config.json"

  # Install ts-node and typescript
  npm install ts-node typescript @types/node

  # Create temporary convert script
  cat > convert-config.js <<EOL
const { register } = require('ts-node');
register({
  compilerOptions: { module: "CommonJS" }
});
const fs = require('fs');
const config = require('./capacitor.config.ts').default;
fs.writeFileSync('capacitor.config.json', JSON.stringify(config, null, 2));
console.log('capacitor.config.json created from TS config');
EOL

  # Run conversion
  node convert-config.js

  # Remove temporary script
  rm convert-config.js
fi

# If capacitor.config.json missing, create minimal config
if [ ! -f "capacitor.config.json" ]; then
  echo "capacitor.config.json missing — generating minimal config..."
  cat > capacitor.config.json <<EOL
{
  "appId": "com.example.app",
  "appName": "MyApp",
  "webDir": ".",
  "bundledWebRuntime": false
}
EOL
fi

# Initialize package.json if missing
if [ ! -f package.json ]; then
  echo "package.json missing — initializing project..."
  npm init -y
fi

# Install Capacitor dependencies
npm install @capacitor/core @capacitor/cli @capacitor/android

# Add Android platform if missing
if [ ! -d "android" ]; then
  echo "Adding Android platform..."
  npx cap add android
fi

# Sync Capacitor
npx cap sync android

echo "Capacitor project ready for Android build"

#!/bin/bash
set -e

BUILD_ID="$1"

if [ -z "$BUILD_ID" ]; then
    echo "ERROR: build_id argument missing."
    exit 1
fi

echo "Preparing build folder: $BUILD_ID"

# ensure builds folder exists
if [ ! -d "builds/$BUILD_ID" ]; then
    echo "ERROR: Folder builds/$BUILD_ID does not exist."
    exit 1
fi

# Start clean workspace
rm -rf app
mkdir app

# Copy uploaded build source into app/
cp -r builds/$BUILD_ID/* app/

cd app

# Install node dependencies (user's project might include its own package.json)
if [ -f package.json ]; then
    echo "Installing user project dependencies..."
    npm install
else
    echo "package.json missing — generating minimal capacitor project..."
    npm init -y
    npm install @capacitor/core @capacitor/cli
fi

# Sync Capacitor platform
npx cap sync android

echo "Capacitor Android project ready."
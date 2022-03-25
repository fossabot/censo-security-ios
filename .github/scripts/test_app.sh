#!/bin/bash

set -eo pipefail

xcodebuild -project "Strike.xcodeproj" \
            -scheme "Strike" \
            -destination platform="iOS Simulator,OS=15.0,name=iPhone 11" \
            clean test | xcpretty

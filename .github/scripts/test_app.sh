#!/bin/bash

set -eo pipefail

xcodebuild -project "Censo.xcodeproj" \
            -scheme "Censo" \
            -destination platform="iOS Simulator,OS=15.0,name=iPhone 11" \
            clean test | xcpretty

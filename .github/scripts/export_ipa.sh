#!/bin/bash

set -eo pipefail

xcodebuild -archivePath $PWD/build/Strike.xcarchive \
            -exportOptionsPlist $EXPORT_OPTIONS_PLIST \
            -exportPath $PWD/build \
            -exportArchive | xcpretty

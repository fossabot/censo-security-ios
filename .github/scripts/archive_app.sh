#!/bin/bash

set -eo pipefail

export BUILD_NUMBER=$(git rev-list HEAD --count)

xcodebuild -project "Censo.xcodeproj" \
            -scheme "${SCHEME}" \
            -configuration "${CONFIGURATION}" \
            -sdk iphoneos \
            -archivePath $PWD/build/Censo.xcarchive \
            CODE_SIGN_STYLE="Manual" \
            DEVELOPMENT_TEAM="VN5U64MGYX" \
            CODE_SIGN_IDENTITY="Apple Distribution: Censo, Inc. (VN5U64MGYX)" \
            PROVISIONING_PROFILE_SPECIFIER="${PROVISIONING_PROFILE}" \
            CURRENT_PROJECT_VERSION="${BUILD_NUMBER}" \
            clean archive | xcpretty

#!/bin/bash

set -eo pipefail

ENVIRONMENT="production"

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -e|--environment)
    ENVIRONMENT="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    shift # past argument
    ;;
esac
done

# Setup environment

export RAYGUN_ACCESS_TOKEN="YXRhQHBlcHBlcmVkc29mdHdhcmUuY29tOkxLSjEyM3BvaWFzZA=="

if [[ $ENVIRONMENT == 'production' ]]; then
  export SCHEME="Strike"
  export CONFIGURATION="Release"
  export PROVISIONING_PROFILE="Strike Mobile Production AppStore"
  export RAYGUN_APPLICATION_ID="282j3o2"
elif [[ $ENVIRONMENT == 'develop' ]]; then
  export ICON_RIBBON="Dev"
  export SCHEME="Strike (Develop)"
  export CONFIGURATION="Release (Develop)"
  export PROVISIONING_PROFILE="Strike Mobile Dev AppStore"
  export RAYGUN_APPLICATION_ID="283703j"
elif [[ $ENVIRONMENT == 'demo' ]]; then
  export ICON_RIBBON="Demo"
  export SCHEME="Strike (Demo)"
  export CONFIGURATION="Release (Demo)"
  export PROVISIONING_PROFILE="Strike Mobile Demo AppStore"
  export RAYGUN_APPLICATION_ID="283706g"
elif [[ $ENVIRONMENT == 'demo2' ]]; then
  export ICON_RIBBON="Demo2"
  export SCHEME="Strike (Demo2)"
  export CONFIGURATION="Release (Demo2)"
  export PROVISIONING_PROFILE="Strike Mobile Demo 2 AppStore"
  export RAYGUN_APPLICATION_ID="283706g"
else
  echo "Unknown environment. Use one of 'develop', 'demo', 'demo2' or 'production'"
fi

# Read AppleID credentials

LINE_NUMBER=0
while read line; do
  if [[ $LINE_NUMBER == 0 ]]; then
    export APPLEID_USERNAME="${line}"
  elif [[ $LINE_NUMBER == 1 ]]; then
    export APPLEID_PASSWORD="${line}"
  else
    break
  fi

  LINE_NUMBER=$((LINE_NUMBER+1))
done < "apple_credentials"

if [[ -z "$APPLEID_USERNAME" ]] || [[ -z "$APPLEID_PASSWORD" ]]; then
  echo "Could not find Apple ID credentials. Make sure the 'apple_credentials' file contains your app-specific username and password"
  exit 1
fi

echo "Running CI steps..."

if [[ ! -z "$ICON_RIBBON" ]]; then
  ./.github/scripts/modify_icon.sh
fi

./.github/scripts/archive_app.sh

./.github/scripts/upload_dsyms.sh

export EXPORT_OPTIONS_PLIST="Strike/ExportOptions.plist"
./.github/scripts/export_ipa.sh

./.github/scripts/publish_testflight.sh

git checkout Strike/Assets.xcassets/AppIcon.appiconset/.

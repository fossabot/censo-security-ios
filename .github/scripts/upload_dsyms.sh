#!/bin/bash

echo "Locating dSYMs"
pushd "$PWD/build/Censo.xcarchive/dSYMs/"
echo "Found dSYMs"
zip -r "censo-dSYMs.zip" "."
echo "Created dSYMs zip"
mv "censo-dSYMs.zip" "../../../censo-dSYMs.zip"
popd

echo "dSYMs zipped: censo-dSYMs.zip"

curl -F "DsymFile=@censo-dSYMs.zip" "https://app.raygun.com/dashboard/$RAYGUN_APPLICATION_ID/settings/symbols?authToken=$RAYGUN_ACCESS_TOKEN"

rm "censo-dSYMs.zip"

#!/bin/bash

echo "Locating dSYMs"
pushd "$PWD/build/Strike.xcarchive/dSYMs/"
echo "Found dSYMs"
zip -r "strike-dSYMs.zip" "."
echo "Created dSYMs zip"
mv "strike-dSYMs.zip" "../../../strike-dSYMs.zip"
popd

echo "dSYMs zipped: strike-dSYMs.zip"

curl -F "DsymFile=@strike-dSYMs.zip" "https://app.raygun.com/dashboard/$RAYGUN_APPLICATION_ID/settings/symbols?authToken=$RAYGUN_ACCESS_TOKEN"

rm "strike-dSYMs.zip"

#!/bin/sh

#  build-universal-xcframework.sh
#  Zip
#
#  Created by Rohan on 13/01/21.
#  Copyright © 2021 Roy Marmelstein. All rights reserved.

set -e

BUILD_DIR=build
NAME=Zip

# clean build folders
if [ -d ${BUILD_DIR} ]; then
  rm -rf ${BUILD_DIR}
fi

if [ -d "${NAME}.xcframework" ]; then
  rm -rf "${NAME}.xcframework"
fi

mkdir ${BUILD_DIR}

# iOS devices
TARGET=iphoneos
xcodebuild archive \
  -scheme ${NAME} \
  -archivePath "./${BUILD_DIR}/${NAME}-${TARGET}.xcarchive" \
  -sdk ${TARGET} \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# iOS simulator
TARGET=iphonesimulator
xcodebuild archive \
  -scheme ${NAME} \
  -archivePath "./${BUILD_DIR}/${NAME}-${TARGET}.xcarchive" \
  -sdk ${TARGET} \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# tvOS devices
TARGET=appletvos
xcodebuild archive \
  -scheme "${NAME} tvOS" \
  -archivePath "./${BUILD_DIR}/${NAME}-${TARGET}.xcarchive" \
  -sdk ${TARGET} \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# tvOS simulator
TARGET=appletvsimulator
xcodebuild archive \
  -scheme "${NAME} tvOS" \
  -archivePath "./${BUILD_DIR}/${NAME}-${TARGET}.xcarchive" \
  -sdk ${TARGET} \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# macOS devices
TARGET=macosx
xcodebuild archive \
  -scheme "${NAME} OSX" \
  -archivePath "./${BUILD_DIR}/${NAME}-${TARGET}.xcarchive" \
  -sdk ${TARGET} \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# packing .framework to .xcframework
FWMK_FILES=$(find "./${BUILD_DIR}" -name "*.framework")
for FWMK_FILE in ${FWMK_FILES}
do
  FWMK_FILES_CMD="-framework ${FWMK_FILE} ${FWMK_FILES_CMD}"
done

xcodebuild -create-xcframework \
  ${FWMK_FILES_CMD} \
  -output "${NAME}.xcframework"

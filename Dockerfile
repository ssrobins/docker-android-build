FROM openjdk:8u171

ENV android_ndk_version r18b
ENV android_sdk_version 28
ENV sdk_tools_version 4333796
ENV cmake_version_major 3
ENV cmake_version_minor 13
ENV cmake_version_patch 0-rc2

# Android NDK
RUN wget --no-verbose https://dl.google.com/android/repository/android-ndk-$android_ndk_version-linux-x86_64.zip
RUN unzip -q android-ndk-$android_ndk_version-linux-x86_64.zip

# Android SDK
RUN wget --no-verbose https://dl.google.com/android/repository/sdk-tools-linux-$sdk_tools_version.zip
RUN unzip -q sdk-tools-linux-$sdk_tools_version.zip
RUN export ANDROID_HOME=$CI_PROJECT_DIR
RUN mkdir ~/.android
RUN touch ~/.android/repositories.cfg
#RUN set +o pipefail
#RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses 1>/dev/null
#RUN set -o pipefail

# Make
RUN apt-get update && apt-get install -y \
  make

# CMake
ENV cmake_installer cmake-$cmake_version_major.$cmake_version_minor.$cmake_version_patch-Linux-x86_64.sh
RUN wget --no-verbose https://cmake.org/files/v$cmake_version_major.$cmake_version_minor/$cmake_installer
RUN sh ./$cmake_installer --prefix=/usr --skip-license


FROM openjdk:8u181

ENV android_ndk_version r18b
ENV android_sdk_version 28
ENV sdk_tools_version 4333796
ENV cmake_version_major 3
ENV cmake_version_minor 13
ENV cmake_version_patch 0-rc2

# Android NDK
RUN cd ~/; \
    wget --no-verbose https://dl.google.com/android/repository/android-ndk-$android_ndk_version-linux-x86_64.zip; \
    unzip -q android-ndk-$android_ndk_version-linux-x86_64.zip; \
    rm android-ndk-$android_ndk_version-linux-x86_64.zip

# Android SDK
RUN cd ~/; \
    wget --no-verbose https://dl.google.com/android/repository/sdk-tools-linux-$sdk_tools_version.zip; \
    unzip -q sdk-tools-linux-$sdk_tools_version.zip; \
    rm sdk-tools-linux-$sdk_tools_version.zip; \
    mkdir ~/.android; \
    touch ~/.android/repositories.cfg; \
    yes | ~/tools/bin/sdkmanager --licenses 1>/dev/null

# Make
RUN apt-get update && apt-get install -y \
  make

# CMake
ENV cmake_installer cmake-$cmake_version_major.$cmake_version_minor.$cmake_version_patch-Linux-x86_64.sh
RUN wget --no-verbose https://cmake.org/files/v$cmake_version_major.$cmake_version_minor/$cmake_installer
RUN sh ./$cmake_installer --prefix=/usr --skip-license
RUN rm $cmake_installer

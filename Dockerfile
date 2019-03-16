FROM openjdk:8u181-jdk-slim-stretch

RUN apt-get update && apt-get install --no-install-recommends -y \
make \
wget && \
rm -rf /var/lib/apt/lists/*

# Android NDK
ENV ANDROID_HOME=/root
ENV android_arch_abi=armeabi-v7a
ENV android_ndk_version=r19c
RUN cd ~/ && \
wget --no-verbose https://dl.google.com/android/repository/android-ndk-$android_ndk_version-linux-x86_64.zip && \
unzip -q android-ndk-$android_ndk_version-linux-x86_64.zip && \
rm android-ndk-$android_ndk_version-linux-x86_64.zip

# Android SDK
ENV android_sdk_version=28
ENV sdk_tools_version=4333796
RUN cd ~/ && \
wget --no-verbose https://dl.google.com/android/repository/sdk-tools-linux-$sdk_tools_version.zip && \
unzip -q sdk-tools-linux-$sdk_tools_version.zip && \
rm sdk-tools-linux-$sdk_tools_version.zip && \
mkdir ~/.android && \
touch ~/.android/repositories.cfg && \
yes | ~/tools/bin/sdkmanager --licenses 1>/dev/null

# CMake
ARG cmake_version_major=3
ARG cmake_version_minor=14
ARG cmake_version_patch=0
ARG cmake_version_full=$cmake_version_major.$cmake_version_minor.$cmake_version_patch
ARG cmake_installer=cmake-$cmake_version_full-Linux-x86_64.sh
RUN wget --no-verbose https://cmake.org/files/v$cmake_version_major.$cmake_version_minor/$cmake_installer && \
sh ./$cmake_installer --prefix=/usr --skip-license && \
rm $cmake_installer
RUN if [ "$cmake_version_full" != "$(cmake --version | head -n 1 | cut -d ' ' -f3)" ]; then echo "CMake version $cmake_version_full not found!"; exit 1; fi

# Conan
ARG conan_version=1.13.0
RUN apt-get update && apt-get install --no-install-recommends -y \
python3-dev python3-pip python3-setuptools python3-wheel && \
pip3 install conan==$conan_version && \
apt-get remove -y \
python3-dev python3-pip python3-setuptools python3-wheel && \
rm -rf /var/lib/apt/lists/*
RUN if [ "$conan_version" != "$(conan --version | grep Conan | cut -d ' ' -f3)" ]; then echo "Conan version $conan_version not found!"; exit 1; fi

RUN java -version

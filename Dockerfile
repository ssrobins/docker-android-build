FROM openjdk:8u212-b04-jdk-slim-stretch

RUN apt-get update && apt-get install --no-install-recommends -y \
git make unzip wget && \
rm -rf /var/lib/apt/lists/*

# Android NDK
ENV ANDROID_HOME=/root
ENV android_ndk_version=r20
RUN cd $ANDROID_HOME && \
wget --no-verbose https://dl.google.com/android/repository/android-ndk-$android_ndk_version-linux-x86_64.zip && \
unzip -q android-ndk-$android_ndk_version-linux-x86_64.zip && \
rm android-ndk-$android_ndk_version-linux-x86_64.zip

# Android SDK
ENV sdk_tools_version=4333796
RUN cd $ANDROID_HOME && \
wget --no-verbose https://dl.google.com/android/repository/sdk-tools-linux-$sdk_tools_version.zip && \
unzip -q sdk-tools-linux-$sdk_tools_version.zip && \
rm sdk-tools-linux-$sdk_tools_version.zip && \
mkdir ~/.android && \
touch ~/.android/repositories.cfg && \
yes | ~/tools/bin/sdkmanager --licenses 1>/dev/null

# Android signing config
ARG ANDROID_KEY_PASSWORD
ARG ANDROID_KEY_STORE
ARG ANDROID_KEY_STORE_PASSWORD
ARG key_store_path=/root/android.jks
ARG gradle_config_dir=/root/.gradle
RUN echo $ANDROID_KEY_STORE | base64 --decode > $key_store_path && \
mkdir $gradle_config_dir && \
echo "ANDROID_KEY_STORE_PATH=$key_store_path\n\
ANDROID_KEY_STORE_PASSWORD=$ANDROID_KEY_STORE_PASSWORD\n\
ANDROID_KEY_ALIAS=androidUploadKey\n\
ANDROID_KEY_PASSWORD=$ANDROID_KEY_PASSWORD" >> $gradle_config_dir/gradle.properties

# CMake
ARG cmake_version=3.15.3
ARG cmake_installer=cmake-$cmake_version-Linux-x86_64.sh
RUN wget --no-verbose https://github.com/Kitware/CMake/releases/download/v$cmake_version/$cmake_installer && \
sh ./$cmake_installer --prefix=/usr --skip-license && \
rm $cmake_installer
RUN if [ "$cmake_version" != "$(cmake --version | head -n 1 | cut -d ' ' -f3)" ]; then echo "CMake version $cmake_version not found!"; exit 1; fi

# Conan
ARG conan_version=1.19.0
RUN apt-get update && apt-get install --no-install-recommends -y \
python3-dev python3-pip python3-setuptools python3-wheel && \
pip3 install conan==$conan_version && \
apt-get remove -y \
python3-dev python3-pip python3-setuptools python3-wheel && \
rm -rf /var/lib/apt/lists/*
RUN if [ "$conan_version" != "$(conan --version | grep Conan | cut -d ' ' -f3)" ]; then echo "Conan version $conan_version not found!"; exit 1; fi

RUN java -version

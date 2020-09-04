ARG jdk_version
FROM amd64/openjdk:$jdk_version-jdk-slim

RUN apt-get update \
&& apt-get install --no-install-recommends -y git unzip wget \
&& rm -rf /var/lib/apt/lists/*

# Android NDK
ARG ndk_version
ARG ndk_zip=android-ndk-r$ndk_version-linux-x86_64.zip
RUN wget --no-verbose https://dl.google.com/android/repository/$ndk_zip \
&& unzip -q $ndk_zip \
&& rm $ndk_zip
ENV ANDROID_NDK_ROOT=/android-ndk-r$ndk_version
ENV PATH=$ANDROID_NDK_ROOT/prebuilt/linux-x86_64/bin:$PATH
RUN make --version

# Android SDK
ARG sdk_tools_version=6609375
ARG sdk_zip=commandlinetools-linux-${sdk_tools_version}_latest.zip
ENV ANDROID_SDK_ROOT=/android-sdk-$sdk_tools_version
RUN mkdir $ANDROID_SDK_ROOT \
&& cd $ANDROID_SDK_ROOT \
&& wget --no-verbose https://dl.google.com/android/repository/$sdk_zip \
&& unzip -q $sdk_zip \
&& rm $sdk_zip \
&& mkdir ~/.android \
&& touch ~/.android/repositories.cfg \
&& yes | $ANDROID_SDK_ROOT/tools/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT --licenses 1>/dev/null

# Android signing config
ARG ANDROID_KEY_PASSWORD
ARG ANDROID_KEY_STORE
ARG ANDROID_KEY_STORE_PASSWORD
ARG key_store_path=/root/android.jks
ARG gradle_config_dir=/root/.gradle
RUN echo $ANDROID_KEY_STORE | base64 --decode > $key_store_path \
&& mkdir $gradle_config_dir \
&& echo "ANDROID_KEY_STORE_PATH=$key_store_path\n\
ANDROID_KEY_STORE_PASSWORD=$ANDROID_KEY_STORE_PASSWORD\n\
ANDROID_KEY_ALIAS=androidUploadKey\n\
ANDROID_KEY_PASSWORD=$ANDROID_KEY_PASSWORD" >> $gradle_config_dir/gradle.properties

# CMake
ARG cmake_version=3.18.2
ARG cmake_installer=cmake-$cmake_version-Linux-x86_64.sh
RUN wget --no-verbose https://github.com/Kitware/CMake/releases/download/v$cmake_version/$cmake_installer \
&& sh ./$cmake_installer --prefix=/usr --skip-license \
&& rm $cmake_installer
RUN if [ "$cmake_version" != "$(cmake --version | head -n 1 | cut -d ' ' -f3)" ]; then echo "CMake version $cmake_version not found!"; exit 1; fi

# Ninja
ARG ninja_version=1.10.1
ARG ninja_zip=ninja-linux.zip
RUN wget --no-verbose https://github.com/ninja-build/ninja/releases/download/v$ninja_version/$ninja_zip \
&& unzip $ninja_zip \
&& cp ninja /usr/bin/ \
&& rm $ninja_zip
RUN if [ "$ninja_version" != "$(ninja --version)" ]; then echo "Ninja version $ninja_version not found!"; exit 1; fi

# Conan
ARG conan_version=1.29.0
RUN apt-get update \
&& apt-get install --no-install-recommends -y python3-minimal python3-pip python3-setuptools python3-wheel \
&& pip3 install conan==$conan_version \
&& apt-get purge -y python3-pip python3-setuptools python3-wheel \
&& apt-get autoremove -y \
&& rm -rf /var/lib/apt/lists/*
RUN if [ "$conan_version" != "$(conan --version | grep Conan | cut -d ' ' -f3)" ]; then echo "Conan version $conan_version not found!"; exit 1; fi

RUN java -version

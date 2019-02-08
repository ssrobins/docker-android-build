FROM openjdk:8u181

ENV ANDROID_HOME=/root
ENV android_arch_abi=armeabi-v7a
ENV android_ndk_version=r18b
ENV android_sdk_version=28
ENV sdk_tools_version=4333796
ARG cmake_version_major=3
ARG cmake_version_minor=14
ARG cmake_version_patch=0-rc1

# Android NDK
RUN cd ~/ && \
    wget --no-verbose https://dl.google.com/android/repository/android-ndk-$android_ndk_version-linux-x86_64.zip && \
    unzip -q android-ndk-$android_ndk_version-linux-x86_64.zip && \
    rm android-ndk-$android_ndk_version-linux-x86_64.zip

# Android SDK
RUN cd ~/ && \
    wget --no-verbose https://dl.google.com/android/repository/sdk-tools-linux-$sdk_tools_version.zip && \
    unzip -q sdk-tools-linux-$sdk_tools_version.zip && \
    rm sdk-tools-linux-$sdk_tools_version.zip && \
    mkdir ~/.android && \
    touch ~/.android/repositories.cfg && \
    yes | ~/tools/bin/sdkmanager --licenses 1>/dev/null

# CMake
ARG cmake_installer=cmake-$cmake_version_major.$cmake_version_minor.$cmake_version_patch-Linux-x86_64.sh
RUN wget --no-verbose https://cmake.org/files/v$cmake_version_major.$cmake_version_minor/$cmake_installer
RUN sh ./$cmake_installer --prefix=/usr --skip-license
RUN rm $cmake_installer

RUN apt-get update && apt-get install -y \
    make \
    # Conan prerequisite
    python3-pip

RUN pip3 install conan
RUN conan remote add conan https://api.bintray.com/conan/stever/conan

# Run 'conan new' to create a default profile then update it
# to prevent an 'OLD ABI' warning.
RUN mkdir test && \
    cd test && \
    conan new test/0.0.1@steve/testing && \
    conan install . && \
    sed -i 's/libstdc++/libstdc++11/' /root/.conan/profiles/default && \
    cd .. && \
    rm -rf test

# Run through a build so build-tools and Gradle get installed
RUN git clone https://gitlab.com/ssrobins/sdl2-example.git && \
    cd sdl2-example && \
    sh ./build_android.sh && \
    cd .. && \
    rm -rf sdl2-example && \
    conan remove \* -f

RUN java -version
RUN cmake --version
RUN conan --version

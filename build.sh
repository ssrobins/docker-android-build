set -e

cd $(dirname "$0")

jdk_version=8u275
ndk_version=21d

if [ -z "$DOCKER_IMAGE_NAME" ]; then
    DOCKER_IMAGE_NAME=docker-android-build
fi

docker build --pull --tag "$DOCKER_IMAGE_NAME:jdk$jdk_version-ndk$ndk_version" . --build-arg "jdk_version=$jdk_version" --build-arg "ndk_version=$ndk_version"

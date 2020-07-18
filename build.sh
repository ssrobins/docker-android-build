set -e

cd $(dirname "$0")

jdk_version=8u262
ndk_version=21d

if [ -z "$CI_REGISTRY_IMAGE" ]; then
    CI_REGISTRY_IMAGE=docker-android-build
fi

docker build --pull --tag "$CI_REGISTRY_IMAGE:jdk$jdk_version-ndk$ndk_version" . --build-arg "jdk_version=$jdk_version" --build-arg "ndk_version=$ndk_version" --build-arg "ANDROID_KEY_PASSWORD=$ANDROID_KEY_PASSWORD" --build-arg "ANDROID_KEY_STORE=$ANDROID_KEY_STORE" --build-arg "ANDROID_KEY_STORE_PASSWORD=$ANDROID_KEY_STORE_PASSWORD"

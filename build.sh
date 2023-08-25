#!/bin/bash

echo
echo "--------------------------------------"
echo "         DerpFest 13.0 Buildbot       "
echo "                  by                  "
echo "                jgudec                "
echo "--------------------------------------"
echo

set -e

BL=$PWD/treble_build_derp
BD=$HOME/builds


export USE_CCACHE=1
export CCACHE_COMPRESS=1
export CCACHE_EXEC=/usr/bin/ccache
export CCACHE_DIR=/mnt/ccache
export CCACHE_EXEC=$(command -v ccache)
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

BUILD="DerpFest"
DERPMK="$BL/derp.mk"

SYNC=true

if [ $1 == "nosync" ]
then
    SYNC=false
fi

initRepos() {
    if [ ! -d .repo ]; then
        echo "--> Initializing workspace"
        repo init -u https://github.com/DerpFest-AOSP/manifest.git -b 13
        echo

        echo "--> Preparing local manifest"
        mkdir -p .repo/local_manifests
        cp $BL/manifest.xml .repo/local_manifests/derp.xml
        echo
    fi
}

syncRepos() {
    echo "--> Syncing repos"
    repo sync -c --force-sync --no-clone-bundle --no-tags -j$(nproc --all)
    echo
}

applyPatches() {
    echo "--> Applying prerequisite patches"
    bash $BL/apply-patches.sh $BL prerequisite
    echo

    echo "--> Applying TrebleDroid patches"
    bash $BL/apply-patches.sh $BL trebledroid
    echo

    echo "--> Applying personal patches"
    bash $BL/apply-patches.sh $BL personal
    echo

    echo "--> Generating makefiles"
    cd device/phh/treble
    cp $BL/derp.mk .
    bash generate.sh derp
    cd ../../..
    echo
}

setupEnv() {
    echo "--> Setting up build environment"
    source build/envsetup.sh &>/dev/null
    mkdir -p $BD
    echo
}

buildTrebleApp() {
    echo "--> Building treble_app"
    cd treble_app
    bash build.sh release
    cp TrebleApp.apk ../vendor/hardware_overlay/TrebleApp/app.apk
    cd ..
    echo
}

buildVariant() {
    echo "--> Building treble_arm64_bvN"
    lunch treble_arm64_bvN-userdebug
    make -j$(nproc --all) installclean
    make -j$(nproc --all) systemimage
    mv $OUT/system.img $BD/system-treble_arm64_bvN.img
    echo
}

generatePackages() {
    echo "--> Generating packages"
    xz -cv $BD/system-treble_arm64_bvN.img -T0 > $BD/DerpFest_arm64-ab-13.0-$BUILD_DATE-UNOFFICIAL.img.xz
    rm -rf $BD/system-*.img
    echo
}

START=`date +%s`
BUILD_DATE="$(date +%Y%m%d)"

if ${SYNC}
then
    echo "ATTENTION: syncing/patching skipped!"
    initRepos
    syncRepos
    applyPatches
fi
setupEnv
buildTrebleApp
buildVariant
generatePackages

END=`date +%s`
ELAPSEDM=$(($(($END-$START))/60))
ELAPSEDS=$(($(($END-$START))-$ELAPSEDM*60))

echo "--> Buildbot completed in $ELAPSEDM minutes and $ELAPSEDS seconds"
echo
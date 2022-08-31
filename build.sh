#!/bin/bash

echo
echo "--------------------------------------"
echo "    Pixel Experience 12.1 Buildbot    "
echo "                  by                  "
echo "                ponces                "
echo "--------------------------------------"
echo
export USE_CCACHE=1
export CCACHE_COMPRESS=1
export CCACHE_EXEC=/usr/bin/ccache
export CCACHE_DIR=/mnt/ccache
export CCACHE_EXEC=$(command -v ccache)

set -e

BL=$PWD/treble_build_pe
BD=$HOME/builds
BRANCH=$1

[ "$BRANCH" == "" ] && BRANCH="twelve"
[ "$BRANCH" == "twelve" ] && BUILD="PixelExperience" || BUILD="PixelExperience_Plus"
[ "$BRANCH" == "twelve" ] && PEMK="$BL/pe.mk" || PEMK="$BL/peplus.mk"

initRepos() {
    if [ ! -d .repo ]; then
        echo "--> Initializing PE workspace"
        repo init -u https://github.com/PixelExperience/manifest -b $BRANCH
        echo

        echo "--> Preparing local manifest"
        mkdir -p .repo/local_manifests
        cp $BL/manifest.xml .repo/local_manifests/pixel.xml
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
    bash $BL/apply-patches.sh $BL prerequisite $BRANCH
    echo
	
	echo "--> Downloading GCam Go"
	cd $BL/gcam_go
	[ ! -f gcam_go.apk ] && curl -LO https://dl.dropboxusercontent.com/s/5f288fvtk1qunfw/gcam_go.apk
	cd ../..
	

    echo "--> Applying PHH patches"
    cd device/phh/treble
    cp $PEMK .
    bash generate.sh $(echo $PEMK | sed "s#$BL/##;s#.mk##")
    cd ../../..
    bash $BL/apply-patches.sh $BL phh $BRANCH
    echo

    echo "--> Applying personal patches"
    bash $BL/apply-patches.sh $BL personal $BRANCH
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
    make installclean
    make -j$(nproc --all) systemimage
    mv $OUT/system.img $BD/system-treble_arm64_bvN.img
    echo
}

generatePackages() {
    echo "--> Generating packages"
	xz -cv $BD/system-treble_arm64_bvN.img -T0 > $BD/"$BUILD"-12.1-Galaxy_S21_S22_Exynos-GSI-$BUILD_DATE-UNOFFICIAL.img.xz
    rm -rf $BD/system-*.img
    echo
}

START=`date +%s`
BUILD_DATE="$(date +%Y%m%d)"

initRepos
syncRepos
applyPatches
setupEnv
buildTrebleApp
buildVariant
generatePackages

END=`date +%s`
ELAPSEDM=$(($(($END-$START))/60))
ELAPSEDS=$(($(($END-$START))-$ELAPSEDM*60))

echo "--> Buildbot completed in $ELAPSEDM minutes and $ELAPSEDS seconds"
echo


## Building TrebleDroid-based LineageOS GSIs ##

Set up your environment by referring to [LineageOS Wiki](https://wiki.lineageos.org/devices/TP1803/build) (mainly "Install the build packages" and "Install the repo command").

Create a new working directory for your LineageOS build and navigate to it:

    mkdir lineage-20-build-td; cd lineage-20-build-td

Initialize your LineageOS workspace:

    repo init -u https://github.com/LineageOS/android.git -b lineage-20.0

Clone both this and the patches repos:

    git clone https://github.com/jgudec/treble_build_s22 lineage_build_unified -b los-20
    git clone https://github.com/jgudec/lineage_patches_unified lineage_patches_unified -b los-20

Finally, start the build script - for example, to build for all supported archs:

    bash lineage_build_unified/buildbot_unified.sh treble 64VN 64GN

Be sure to update the cloned repos from time to time!

---

Note: VNDKLite targets are generated from built images instead of source-built - refer to [sas-creator](https://github.com/AndyCGYan/sas-creator).

---

This script is also used to make device-specific and/or personal builds. To do so, understand the script, and try the `device` and `personal` keywords.

#!/bin/bash

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

# Build dir
BUILD_DIR="kernel_platform"

# Kernel repo dir
KERNEL_DIR="msm-kernel"

# Functions

function clean {

    rm -rf exports.txt
    rm -rf kernel_platform/out/
    rm -rf kernel_platform/build.config
    rm -rf device/
    rm -rf out/

}

function clone_vendor_repo {

    cd $BUILD_DIR
    if [ -d "msm-kernel" ] 
    then
        echo "kernel directory exists..."
    else
        echo "Error: vendor directory does not exists... cloning xiaomeme kernel"
        git clone https://github.com/yarpiin/kernel_xiaomi_sm8450_common.git -b sm8450 $KERNEL_DIR
    cd ..
    fi
}

function build_cupid_kernel {

    export TARGET_BOARD_PLATFORM="cupid"
    export TARGET_BUILD_VARIANT=user
    export ANDROID_BUILD_TOP=$(pwd)
    export ANDROID_PRODUCT_OUT=${ANDROID_BUILD_TOP}/out/target/product/${TARGET_BOARD_PLATFORM}
    export OUT_DIR=${ANDROID_BUILD_TOP}/out/msm-kernel-${TARGET_BOARD_PLATFORM}
    export KBUILD_EXTRA_SYMBOLS=${ANDROID_BUILD_TOP}/out/vendor/qcom/opensource/mmrm-driver/Module.symvers

    export EXT_MODULES="
      ../vendor/qcom/opensource/mmrm-driver
      ../vendor/qcom/opensource/audio-kernel
      ../vendor/qcom/opensource/camera-kernel
      ../vendor/qcom/opensource/dataipa/drivers/platform/msm
      ../vendor/qcom/opensource/datarmnet/core
      ../vendor/qcom/opensource/datarmnet-ext/sch
      ../vendor/qcom/opensource/datarmnet-ext/offload
      ../vendor/qcom/opensource/datarmnet-ext/perf_tether
      ../vendor/qcom/opensource/datarmnet-ext/shs
      ../vendor/qcom/opensource/datarmnet-ext/wlan
      ../vendor/qcom/opensource/datarmnet-ext/aps
      ../vendor/qcom/opensource/datarmnet-ext/perf
      ../vendor/qcom/opensource/display-drivers/msm
      ../vendor/qcom/opensource/cvp-kernel
      ../vendor/qcom/opensource/eva-kernel
      ../vendor/qcom/opensource/video-driver
    "

    export LTO=thin

    RECOMPILE_KERNEL=1 ./kernel_platform/build/android/prepare_vendor.sh ${TARGET_BOARD_PLATFORM} gki

}


DATE_START=$(date +"%s")

echo -e "${green}"
echo "Xiaomi Kernel Build Script"
echo

echo "-----------------------------"
echo "Kernel Platform: Xiaomi Mi12"
echo "-----------------------------"

echo -e "${red}"; echo -e "${blink_red}"; echo "$YARPIIN_VER"; echo -e "${restore}";

echo -e "${green}"
echo "---------------------------"
echo "      Building Kernel"
echo "---------------------------"
echo -e "${restore}"

while read -p "Do you want to clean (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to clone kernel repo (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		clone_vendor_repo
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build MI 12 kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		build_cupid_kernel
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

echo
echo
echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo


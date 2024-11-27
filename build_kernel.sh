#!/usr/bin/env bash

# Main Declaration
function env() {
export KERNEL_NAME=UWU-Kernel
export KERNEL_ROOTDIR=${PWD}
export DEVICE_DEFCONFIG=mt6737t-grandpplte_defconfig
export IMAGE=${PWD}/out/arch/arm/boot/zImage-dtb
DATE=$(date +"%F-%S")
START=$(date +"%s")
export KBUILD_BUILD_USER=samsung
export KBUILD_BUILD_HOST=MRT-Project
export BOT_MSG_URL="https://api.telegram.org/bot${tg_token}/sendMessage"
export BOT_MSG_URL2="https://api.telegram.org/bot${tg_token}"
}
# Checking environtment
# Warning !! Dont Change anything there without known reason.
function check() {
echo ================================================
echo "              _  __  ____  ____               "
echo "             / |/ / / __/ / __/               "
echo "      __    /    / / _/  _\ \    __           "
echo "     /_/   /_/|_/ /_/   /___/   /_/           "
echo "    ___  ___  ____     _________________      "
echo "   / _ \/ _ \/ __ \__ / / __/ ___/_  __/      "
echo "  / ___/ , _/ /_/ / // / _// /__  / /         "
echo " /_/  /_/|_|\____/\___/___/\___/ /_/          "
echo ================================================
echo BUILDER NAME = ${KBUILD_BUILD_USER}
echo BUILDER HOSTNAME = ${KBUILD_BUILD_HOST}
echo DEVICE_DEFCONFIG = ${DEVICE_DEFCONFIG}
echo KERNEL_ROOTDIR = ${KERNEL_ROOTDIR}
echo ================================================
}
tg_post_msg() {
  curl -s -X POST "${BOT_MSG_URL}" -d chat_id="${tg_chat_id}" \
  -d "disable_web_page_preview=true" \
  -d "parse_mode=html" \
  -d text="$1"
}
# Peocces Compile
function compile() {
cd ${KERNEL_ROOTDIR}
make -j$(nproc) O=${PWD}/out ARCH=arm ${DEVICE_DEFCONFIG}
make -j$(nproc) ARCH=arm O=${PWD}/out \
    CROSS_COMPILE=${PWD}/PLATFORM/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi- \
    CROSS_COMPILE_ARM32=${PWD}/PLATFORM/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-

    ls ${IMAGE}
   if ! [ -a "${IMAGE}" ]; then
	finerr
   fi
	git clone --depth=1 https://github.com/AnGgIt86/AnyKernel3 ${PWD}/AnyKernel
	cp ${IMAGE} ${PWD}/AnyKernel
}
# Push kernel
function push() {
    cd ${PWD}/AnyKernel
    zip -r9 ${KERNEL_NAME}-${DEVICE_CODENAME}-${DATE}.zip *
    ZIP=$(echo *.zip)
    curl -F document=@${ZIP} "https://api.telegram.org/bot${tg_token}/sendDocument" \
        -F chat_id="${tg_chat_id}" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="
Compile took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s)."
}
# Find Error
function finerr() {
    wget https://github.com/AnGgIt86/android_kernel_samsung_grandppltedx/suites/31390358520/logs?attempt=1 -O build.log.zip
	curl -F document=@build.log.zip "https://api.telegram.org/bot${tg_token}/sendDocument" \
        -F chat_id="${tg_chat_id}" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="==============================%0A<b>    Building Kernel Failed [❌]</b>%0A<b>        Jiancog Tenan 🤬</b>%0A==============================" \
    curl -s -X POST "${BOT_MSG_URL2}/sendSticker" \
        -d sticker="CAACAgQAAx0EabRMmQACAnRjEUAXBTK1Ei_zbJNPFH7WCLzSdAACpBEAAqbxcR716gIrH45xdB4E" \
        -d chat_id="${tg_chat_id}"
    exit 1
}

env
check
compile
END=$(date +"%s")
DIFF=$(($END - $START))
push

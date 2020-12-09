#!/bin/bash

BOLD='\033[1m'
GRN='\033[01;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[01;31m'
RST='\033[0m'
echo "Cloning dependencies if they don't exist...."

if [ ! -d clang ]
then
git clone --depth=1 https://github.com/CPH1859/prebuilt_clang-6.0.2 clang

fi

if [ ! -d gcc32 ]
then
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 gcc32
fi

if [ ! -d gcc ]
then
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 gcc
fi

if [ ! -d AnyKernel ]
then
git clone https://gitlab.com/Baibhab34/AnyKernel3.git -b rm1 --depth=1 AnyKernel
fi

echo "Done"

echo "Cleaning old files in AnyKernel directory...."
rm AnyKernel/Stock* &>> /dev/null
rm AnyKernel/Image.gz-dtb &>> /dev/null

KERNEL_DIR=$(pwd)
IMAGE="${KERNEL_DIR}/out/arch/arm64/boot/Image.gz-dtb"
TANGGAL=$(date +"%Y%m%d-%H")
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
PATH="${KERNEL_DIR}/clang/bin:${KERNEL_DIR}/gcc/bin:${KERNEL_DIR}/gcc32/bin:${PATH}"
export KBUILD_COMPILER_STRING="$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export ARCH=arm64
export KBUILD_BUILD_USER=ayush
export KBUILD_BUILD_HOST=gcp

echo "Cleaning old Image.gz-dtb if it exists......"
if [ -f "$IMAGE" ]
then
rm $IMAGE
fi


# Compile plox
function compile() {

    echo -e "${CYAN}"
    make -j$(nproc) O=out ARCH=arm64 oppo6771_17065_defconfig
    make -j$(nproc) O=out \
                    ARCH=arm64 \
                    CC=clang \
                    CLANG_TRIPLE=aarch64-linux-gnu- \
                    CROSS_COMPILE=aarch64-linux-android- \
                    CROSS_COMPILE_ARM32=arm-linux-androideabi-
   echo -e "${RST}"
SUCCESS=$?
	if [ $SUCCESS -eq 0 ] && [ -f "$IMAGE" ]
        	then
		echo -e "${GRN}"
		echo "------------------------------------------------------------"
		echo "Compilation successful..."
        	echo "Image.gz-dt can be found at out/arch/arm64/boot/Image.gz-dtb"
    		cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
		echo  "------------------------------------------------------------"
		echo -e "${RST}"
	else
		echo -e "${RED}"
                echo "------------------------------------------------------------"
		echo "Compilation failed..check build logs for errors"
                echo "------------------------------------------------------------"
		echo -e "${RST}"
	fi

}
# Zipping
function zipping() {
    echo -e "${YELLOW}"
    echo "Creating a flashable zip....."
    cd AnyKernel || exit 1
    zip -r9 Stock-CPH1859-${TANGGAL}.zip * > /dev/null 2>&1
    cd ..
    echo "Zip stored at AnyKernel/Stock-CPH1859-${TANGGAL}.zip"
    echo -e "${RST}"
}
compile

if [ $SUCCESS -eq 0 ] && [ -f "$IMAGE" ]
then
	zipping
fi

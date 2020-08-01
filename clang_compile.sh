#!/bin/bash
echo "Cloning dependencies if they don't exist...."

if [ ! -d clang ]
git clone --depth=1 https://github.com/crdroidmod/android_prebuilts_clang_host_linux-x86_clang-5407736 clang

if [ ! -d gcc32 ]
git clone --depth=1 https://github.com/KudProject/arm-linux-androideabi-4.9 gcc32

if [ ! -d gcc ]
git clone --depth=1 https://github.com/KudProject/aarch64-linux-android-4.9 gcc

if [ ! -d AnyKernel ]
git clone https://gitlab.com/Baibhab34/AnyKernel3.git -b rm1 --depth=1 AnyKernel
echo "Done"


KERNEL_DIR=$(pwd)
IMAGE="${KERNEL_DIR}/out/arch/arm64/boot/Image.gz-dtb"
TANGGAL=$(date +"%Y%m%d-%H")
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
PATH="${KERNEL_DIR}/clang/bin:${KERNEL_DIR}/gcc/bin:${KERNEL_DIR}/gcc32/bin:${PATH}"
export KBUILD_COMPILER_STRING="$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export ARCH=arm64
export KBUILD_BUILD_USER=ayush
export KBUILD_BUILD_HOST=gcp

# Compile plox
function compile() {
    make -j$(nproc) O=out ARCH=arm64 oppo6771_17065_defconfig
    make -j$(nproc) O=out \
                    ARCH=arm64 \
                    CC=clang \
                    CLANG_TRIPLE=aarch64-linux-gnu- \
                    CROSS_COMPILE=aarch64-linux-android- \
                    CROSS_COMPILE_ARM32=arm-linux-androideabi-
SUCCESS=$?
	if [ $SUCCESS -eq 0 ]
        	then
		echo "Compilation successful..."
        	echo "Image.gz-dt can be found at out/arch/arm64/boot/Image.gz-dtb"
    		cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
	else
		echo "Compilation failed..check build logs for errors"
	fi

}
# Zipping
function zipping() {
    echo "Creating a flashable zip....."
    cd AnyKernel || exit 1
    zip -r9 Stormbreaker-CPH1859-${TANGGAL}.zip * > /dev/null 2>&1
    cd ..
    echo "Zip stored at AnyKernel/Stormbreaker-CPH1859-${TANGGAL}.zip"
}
compile

if [ $SUCCESS -eq 0 ]
then
	zipping
fi

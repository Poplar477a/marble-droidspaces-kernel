#!/usr/bin/env bash
# Build script for LineageOS 24 marble custom kernel (Droidspaces + BakaSU)
set -euo pipefail

KERNEL_SRC="${1:-.}"
OUT_DIR="${2:-out}"
JOBS="${JOBS:-$(nproc)}"

echo "=== Building custom kernel in ${OUT_DIR} with ${JOBS} jobs ==="
cd "${KERNEL_SRC}"

# 1. Ensure required LLVM/clang toolchain is present
export ARCH=arm64
export SUBARCH=arm64
export CC=clang
export LLVM=1
export LLVM_IAS=1

# 2. Check olddefconfig / auto.conf
if [ ! -f "${OUT_DIR}/.config" ]; then
    echo "Error: ${OUT_DIR}/.config not found. Please copy your defconfig first."
    exit 1
fi

make O="${OUT_DIR}" ARCH=arm64 LLVM=1 LLVM_IAS=1 CC=clang olddefconfig
rm -f "${OUT_DIR}/include/config/auto.conf" "${OUT_DIR}/include/config/auto.conf.cmd"
make O="${OUT_DIR}" ARCH=arm64 LLVM=1 LLVM_IAS=1 CC=clang syncconfig

echo "Kernel release target: $(make O="${OUT_DIR}" ARCH=arm64 LLVM=1 LLVM_IAS=1 CC=clang kernelrelease 2>&1 | tail -1)"

# 3. Compile Image
make O="${OUT_DIR}" ARCH=arm64 LLVM=1 LLVM_IAS=1 CC=clang -j"${JOBS}" Image

echo "=== Build finished: ${OUT_DIR}/arch/arm64/boot/Image ==="

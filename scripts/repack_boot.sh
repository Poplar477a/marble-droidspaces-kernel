#!/usr/bin/env bash
# Repack boot.img using stock ramdisk and custom Image
set -euo pipefail

STOCK_BOOT="${1:-boot.img}"
KERNEL_IMAGE="${2:-Image}"
OUT_BOOT="${3:-los-ksu-boot.img}"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "${TMP_DIR}"' EXIT

echo "=== Unpacking ${STOCK_BOOT} ==="
unpack_bootimg --boot_img "${STOCK_BOOT}" --out "${TMP_DIR}"

echo "=== Repacking with custom ${KERNEL_IMAGE} ==="
mkbootimg \
    --header_version 4 \
    --os_version 17.0.0 \
    --os_patch_level 2026-10 \
    --kernel "${KERNEL_IMAGE}" \
    --ramdisk "${TMP_DIR}/ramdisk" \
    --pagesize 4096 \
    -o "${OUT_BOOT}"

echo "=== Generated boot image: ${OUT_BOOT} ($(stat -c %s "${OUT_BOOT}") bytes) ==="

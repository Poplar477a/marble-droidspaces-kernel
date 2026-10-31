#!/usr/bin/env bash
# Package Image into AnyKernel3 zip
set -euo pipefail

IMAGE_PATH="${1:-out/arch/arm64/boot/Image}"
OUTPUT_ZIP="${2:-LineageOS24-marble-droidspaces-ksu-AK3.zip}"
AK3_DIR="${3:-anykernel3}"

if [ ! -f "${IMAGE_PATH}" ]; then
    echo "Error: Image not found at ${IMAGE_PATH}"
    exit 1
fi

TMP_DIR=$(mktemp -d)
trap 'rm -rf "${TMP_DIR}"' EXIT

cp -r "${AK3_DIR}"/* "${TMP_DIR}/"
cp "${IMAGE_PATH}" "${TMP_DIR}/Image"

(cd "${TMP_DIR}" && zip -r -q "${OLDPWD}/${OUTPUT_ZIP}" . -x '*.git*')

echo "=== Generated AnyKernel3 zip: ${OUTPUT_ZIP} ($(stat -c %s "${OUTPUT_ZIP}") bytes) ==="

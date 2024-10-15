#!/bin/sh

ACCOUNT_CODE=$1

SCRIPT_DIR=$(cd $(dirname $0); pwd)
WORKSPACE_DIR="${SCRIPT_DIR}/../../"
INPUT_FILE="${SCRIPT_DIR}/../build_integration/input.json"

cd ${WORKSPACE_DIR}../circuits && yarn gen-input \
    --account-code $ACCOUNT_CODE \
    --input-file $INPUT_FILE \
    --prove
exit 0
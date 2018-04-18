#!/bin/bash

IFS="="
while read -r paramName paramValue
do
    if [ -n "$paramName" ]; then
        eval "export $paramName=${paramValue//\"/}"
    fi
done < <(grep '^\w\+ *=' "$1")

echo "=== Verify files"
source $THIS_DIR/scripts/auto_verify_files.sh


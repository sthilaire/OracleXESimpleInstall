#!/bin/bash

IFS="="
while read -r paramName paramValue
do
    if [ -n "$paramName" ]; then
        eval "export $paramName=${paramValue//\"/}"
    fi
done < <(grep '^\w\+ *=' "$1")



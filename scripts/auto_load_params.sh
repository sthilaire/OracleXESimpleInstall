#!/bin/bash

## script used to EXPORT each parameter to make them available to subscripts
## this may or may not be used in this case as I may prefer to just reload at the top
## to allow scripts to be run independantly

IFS="="
while read -r paramName paramValue
do
    if [ -n "$paramName" ]; then
        eval "export $paramName=${paramValue//\"/}"
    fi
done < <(grep '^\w\+ *=' "$1")



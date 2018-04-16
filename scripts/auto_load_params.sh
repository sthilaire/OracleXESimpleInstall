#!/bin/bash -x

IFS="="
while read -r paramName paramValue
do
    #echo "Content of $paramName is ${paramValue//\"/}"
    if [ -n "$paramName" ]; then
        echo "parma Name = " $paramName
        eval "export $paramName=${paramValue//\"/}"
    fi
done < <(grep '^\w\+ *=' "$1")


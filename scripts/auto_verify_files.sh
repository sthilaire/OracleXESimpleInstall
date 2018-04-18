#!/bin/bash

if [[ $XE_INSTALL = "Y" ]]
then

    export XE_ZIP=$(ls -1 $ZIPS_PATH/oracle-xe*.zip 2>/dev/null)

    if [[ -f "$XE_ZIP"  ]]
    then 
        md5sum $XE_ZIP
    else
	ls -1 $ZIPS_PATH/oracle-xe*.zip
        echo "... XE install requested, but file does not exist.  Stopping." && exit 1
    fi
else
    echo "... XE install not requested. continuing..."
fi


if [[ $ORDS_INSTALL = "Y" ]]
then

    export ORDS_ZIP=$(ls -1 $ZIPS_PATH/ords*.zip 2>/dev/null)

    if [[ -f "$ORDS_ZIP"  ]]
    then
        md5sum $ORDS_ZIP
    else
        echo "... ORDS install requested, but file does not exist.  Stopping." && exit 1
    fi
else
    echo "... ORDS install not requested. continuing..."
fi


if [[ $APEX_UPGRADE = "Y" ]]
then

    export APEX_ZIP=$(ls -1 $ZIPS_PATH/apex*.zip 2>/dev/null)

    if [[ -f "$APEX_ZIP"  ]]
    then
        md5sum $APEX_ZIP
    else
        echo "... APEX upgrade requested, but file does not exist.  Stopping." && exit 1
    fi
else
    echo "... APEX upgrade not requested. continuing..."
fi


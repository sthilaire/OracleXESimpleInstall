#!/bin/bash

echo "... unzip XE"
if [[ -f "$XE_ZIP"  ]]
then 
    unzip -q $XE_ZIP -d $ZIPS_PATH/working
else
    echo "... Missing: $XE_ZIP"
    echo "... XE install requested, but file does not exist.  Why are you here??" && exit 0
fi

echo "... Install the XE RPM"   
rpm -ivh $(ls -1 $ZIPS_PATH/working/Disk1/oracle-xe*.rpm) > $ZIPS_PATH/XeSilentInstall.log

echo "... Config XE"
cp $THIS_DIR/scripts/xe.rsp $ZIPS_PATH/working/xe.rsp
sed -i "s|{{DB_PASSWORD}}|$XE_DEFAULT_PASSWORD|g" $ZIPS_PATH/working/xe.rsp

echo "... (this may take a few minutes)..."
echo "... log located at: $ZIPS_PATH/XeSilentConfig.log"

/etc/init.d/oracle-xe configure responseFile=$ZIPS_PATH/working/xe.rsp > $ZIPS_PATH/XeSilentConfig.log

echo "... Finished Config"
echo "..."
echo "... NOTE: add the following to your ~/.bash_profile for any user that will use client tools"
echo $(ls -1 /u01/app/oracle/product/*/xe/bin/oracle_env.sh)


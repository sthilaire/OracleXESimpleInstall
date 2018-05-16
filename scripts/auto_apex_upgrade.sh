#!/bin/bash

echo "..."
echo "... auto_apex_upgrade.sh"
echo "..."
echo "... unzip APEX"
if [[ -f "$APEX_ZIP"  ]]
then 
    unzip -q "$APEX_ZIP" -d "$ZIPS_PATH/working"
else
    echo "... Missing: $APEX_ZIP"
    echo "... APEX upgrade requested, but file does not exist.  Why are you here??" && exit 0
fi

## Set environment
source $(ls -1 /u01/app/oracle/product/*/xe/bin/oracle_env.sh)

cd $ZIPS_PATH/working/apex

echo "... Install the APEX Upgrade"   
## Connect and run installation script with default options
sqlplus -s sys/$XE_DEFAULT_PASSWORD@xe as sysdba @apexins.sql SYSAUX SYSAUX TEMP /i/

cd $THIS_DIR
## Additional config Scripts here
sqlplus -s sys/$XE_DEFAULT_PASSWORD@xe as sysdba @scripts/xe_adjustments.sql

echo "... Finished APEX Upgade"
echo "..."
echo "... NOTE: add the following to your ~/.bash_profile for any user that will use client tools"
echo "... " $(ls -1 /u01/app/oracle/product/*/xe/bin/oracle_env.sh)


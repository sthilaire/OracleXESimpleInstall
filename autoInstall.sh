#!/bin/bash 

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Debug option to show commands
[ -n "$AUTO_DEBUG" ] && set -x

# Current directory for relative reference
export THIS_DIR=$(cd $(dirname "$0") && pwd )
cd $THIS_DIR

echo "=== Load Parameters"
source $THIS_DIR/scripts/auto_load_params.sh $THIS_DIR/scripts/autoInstall.params

env | grep ZIPS

if [[ $XE_INSTALL = "Y" ]]
then
    echo "=== Install XE Database"
    echo "...  file = " $XE_ZIP
    $THIS_DIR/scripts/auto_xe_install.sh
else
    echo "... not installing XE"
fi

if [[ $ORDS_INSTALL = "Y" ]]
then
    echo "=== Install ORDS"
    echo "... ords file = " $ORDS_ZIP
    $THIS_DIR/scripts/auto_ords_install.sh
else
    echo "... not installing ORDS"
fi



echo "=== Done"

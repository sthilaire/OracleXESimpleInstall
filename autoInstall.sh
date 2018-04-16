#!/bin/bash 

## expected programs
_DIRNAME="/usr/bin/dirname"

# Debug option
[ -n "$AUTO_DEBUG" ] && set -x

# Current directory for relative reference
export THIS_DIR=$(cd $($_DIRNAME "$0") && pwd )

echo "=== Load Parameters"
#source $THIS_DIR/scripts/autoInstall.params
source $THIS_DIR/scripts/auto_load_params.sh $THIS_DIR/scripts/autoInstall.params
env | grep ZIPS

echo "=== Install ORDS"
echo "... zips in directory" $ZIPS_PATH
$THIS_DIR/scripts/auto_ords_install.sh

echo "=== Done"

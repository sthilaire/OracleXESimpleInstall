#!/bin/bash -e
#
#  ./scripts/xe_post_install.sh /stage/OracleXESimpleInstall/scripts autoInstall.params
#  $1 : Script Directory
#  $2 : Parameter File
#  $3 : Log Directory

echo "=="
echo "== Script: $BASH_SOURCE"
echo "=="

#==============================================================================
#  Step 0: Setup and Verify
#

# Script directory is defined
if [[ -z $OSI_SCRIPT_DIR && -d $1 ]]
then
    OSI_SCRIPT_DIR=$1
fi

# Load utilility functions if needed
if [[ -z $(type -t f_functions_loaded) ]]
then
    OSI_SCRIPT_DIR=$1
    if [[ -f $OSI_SCRIPT_DIR/function_definitions.sh ]]
    then
        source $OSI_SCRIPT_DIR/function_definitions.sh
    else
        echo "ERROR: Scripts could not be located.  Exiting..."
        exit 1
    fi
else
    echo "... Functions loaded"
fi

# Load Parameter file
f_load_parameter_file $2

# Load XE environment
f_load_xe_env

# Test for ROOT user
f_is_root

# Load Parameter file
f_set_osi_log_dir
f_start_logging

echo "This is a test..."
echo "...The End..."

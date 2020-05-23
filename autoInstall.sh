#!/bin/bash -e
#
#  autoInstall.sh
#
#  Purpose:
#    Primary installation script used to orchestrate the compelte process
#
#  Parameters:
#    $1 : Parameter file name
#

echo "=="
echo "== Script: $BASH_SOURCE"
echo "=="

#==============================================================================
#  Step 0: Setup and Verify
#

# Current directory for relative reference
export OSI_BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export OSI_SCRIPT_DIR="$OSI_BASE_DIR/scripts"
cd $OSI_BASE_DIR

# Load utilility functions
source $OSI_SCRIPT_DIR/function_definitions.sh

f_set_osi_log_dir
f_start_logging

# Test for ROOT user
f_is_root

# Load parameter file
## OSI_PARAM_FILE is set in the function
f_load_parameter_file $1

# Debug option to show commands
[[ $OSI_SCRIPT_DEBUG = "Y" ]] && set -x

echo "Base Directory used: $OSI_BASE_DIR"


if [[ $OSI_CENTOS_ADJUST = "Y" ]]
then
    echo "=== CentOS Adjustments"
    $OSI_SCRIPT_DIR/centos_pre_install.sh
else
    echo "... not installing CentOS tools"
fi

#==============================================================================
#  Step 1: Oracle XE
#
if [[ $OSI_XE_INSTALL = "Y" ]]
then
    echo "=== Install XE"
    $OSI_SCRIPT_DIR/xe_install.sh $OSI_SCRIPT_DIR $OSI_PARAM_FILE
    $OSI_SCRIPT_DIR/xe_post_install.sh $OSI_SCRIPT_DIR $OSI_PARAM_FILE

else
    echo "... not installing XE"
fi

#==============================================================================
#  Step 2: Oracle APEX
#
if [[ $OSI_APEX_INSTALL = "Y" ]]
then
    echo "=== Install APEX"
    $OSI_SCRIPT_DIR/apex_install.sh $OSI_SCRIPT_DIR $OSI_PARAM_FILE
else
    echo "... not upgrading APEX"
fi

#==============================================================================
#  Step 3: Oracle Rest Data Services
#
if [[ $OSI_ORDS_INSTALL = "Y" ]]
then
    echo "=== Install ORDS"
    $OSI_BASE_DIR/scripts/ords_install.sh $OSI_SCRIPT_DIR $OSI_PARAM_FILE
else
    echo "... not installing ORDS"
fi



echo "=== Done"

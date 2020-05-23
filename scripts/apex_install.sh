#!/bin/bash
set -ex
#
#  xe_install.sh /stage/OracleXESimpleInstall/scripts autoInstall.params
#  $1 : Script Directory
#  $2 : Parameter File
#  $3 : Log Directory

echo "== Script: $BASH_SOURCE"

#==============================================================================
#  Step 0: Setup and Verify
#

# Load utilility functions
if [[ -z $(type -t f_functions_loaded) || -z "$OSI_SCRIPT_DIR" ]]
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

# Do we have an APEX zip
if [[ ! -f "$OSI_APEX_ZIP" ]]
then
    # try to find it
    OSI_APEX_ZIP=$(find "$OSI_STAGE_DIR" -iname apex*.zip)
    if [[ ! -f "$OSI_APEX_ZIP" ]]; then
        # Exit - we can not continue without a zip
        echo "ERROR - Unable to locate APEX zip file."
        exit 1
    fi
fi

#==============================================================================
#  Step 1: APEX Install
#

echo "..."
echo "... APEX Install"
echo "..."

echo "... get apex version"

l_apex_version_file=$(unzip -Z1 ${OSI_APEX_ZIP} | grep apex_version.js)
export OSI_APEX_VERSION=$(unzip -p ${OSI_APEX_ZIP} ${l_apex_version_file} | grep -oE "[0-9.]+" )
mkdir -p ${ORACLE_BASE}/apex/images/${OSI_APEX_VERSION}
l_apex_install_dir=${ORACLE_BASE}/apex/${OSI_APEX_VERSION}
echo "... unzip APEX into ${l_apex_install_dir}"
unzip -o -q "${OSI_APEX_ZIP}" -d "$l_apex_install_dir"

# Adjust Images
echo "... move imges"
mv ${l_apex_install_dir}/apex/images ${ORACLE_BASE}/apex/images/${OSI_APEX_VERSION}
# Create a link to keep structure in place
ln -s ${ORACLE_BASE}/apex/images/${OSI_APEX_VERSION} ${l_apex_install_dir}/apex/images


cd ${l_apex_install_dir}/apex
echo "... Install the APEX"
## Connect and run installation script with default options
sqlplus sys/${OSI_XE_DEFAULT_PASSWORD}@//localhost/${OSI_XE_DEFAULT_PDB} as sysdba << EOF
@apexins.sql SYSAUX SYSAUX TEMP /i/${OSI_APEX_VERSION}/
exit;
EOF

# APEX rest config (different from ORDS REST)
sqlplus sys/${OSI_XE_DEFAULT_PASSWORD}@//localhost/${OSI_XE_DEFAULT_PDB} as sysdba << EOF
@apex_rest_config.sql ${OSI_XE_DEFAULT_PASSWORD} ${OSI_XE_DEFAULT_PASSWORD}
exit;
EOF

# APEX rest config (different from ORDS REST)
sqlplus sys/${OSI_XE_DEFAULT_PASSWORD}@//localhost/${OSI_XE_DEFAULT_PDB} as sysdba << EOF
alter user apex_public_user account unlock;
exit;
EOF

echo "... Finished APEX Install"

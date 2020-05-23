#!/bin/bash -e
#
#  ./scripts/xe_install.sh /stage/OracleXESimpleInstall autoInstall.params
#  $1 : Script Directory
#  $2 : Parameter File
#

echo "=="
echo "== Script: $BASH_SOURCE"
echo "=="

#==============================================================================
#  Step 0: Setup and Verify
#

if [[ -z $OSI_SCRIPT_DIR && -d $1 ]]
then
    OSI_SCRIPT_DIR=$1
fi

# Load utilility functions
if [[ -z $(type -t f_functions_loaded) ]]
then
    if [ -f $OSI_SCRIPT_DIR/function_definitions.sh ]
    then
        source $OSI_SCRIPT_DIR/function_definitions.sh
    else
        echo "ERROR: Scripts could not be located.  Exiting..."
        exit 1
    fi
else
    echo "... Functions loaded"
fi

# Test for ROOT user
f_is_root

# Load Parameter file
f_load_parameter_file $2
f_set_osi_log_dir


# Check Parameters
if [[ "$OSI_XE_INSTALL" != "Y" ]]
then
    echo "... not installing XE"
    exit 0
fi


# Verify RPMs Exist
if [ -f "$OSI_STAGE_DIR/$OSI_XE_PREINSTALL_FILE" ]
then
    echo "... XE preInstall rpm found."
    # f_checksum $OSI_STAGE_DIR/$OSI_XE_PREINSTALL_FILE
else
    echo "ERROR: Unable to locate PreInstall rpm = $OSI_STAGE_DIR/$OSI_XE_PREINSTALL_FILE"
    exit 1
fi

if [ -f "$OSI_STAGE_DIR/$OSI_XE_INSTALL_FILE" ]
then
    echo "... XE rpm found."
    # f_checksum $OSI_STAGE_DIR/$OSI_XE_INSTALL_FILE
else
    echo "ERROR: Unable to locate XE rpm = $OSI_STAGE_DIR/$OSI_XE_INSTALL_FILE"
    exit 1
fi

#==============================================================================
#  Step 1: RPM Installations
#
#  https://docs.oracle.com/en/database/oracle/oracle-database/18/xeinl/performing-silent-installation.html
#

echo "=== Install XE Database RPM"

echo "... Install the XE PREINSTALL RPM"
yum localinstall -y $OSI_STAGE_DIR/$OSI_XE_PREINSTALL_FILE
## > /xe_logs/XEsilentinstall.log 2>&1

echo "... Install the XE RPM"
yum localinstall -y $OSI_STAGE_DIR/$OSI_XE_INSTALL_FILE

echo "... Config XE"
echo "... log located at: $OSI_STAGE_DIR/XEsilentinstall.log"
echo "... (this may take a few minutes)..."

# /etc/init.d/oracle-xe-18c configure >> /xe_logs/XEsilentinstall.log 2>&1
(echo "$OSI_XE_DEFAULT_PASSWORD"; echo "$OSI_XE_DEFAULT_PASSWORD";) | /etc/init.d/oracle-xe-18c configure
# >> ${OSI_LOG_DIR}XEsilentinstall.log 2>&1

# Enable automatic start of the XE service
# OEL7
# systemctl start oracle-xe-18c
# systemctl enable oracle-xe-18c
# CentOS 7
service oracle-xe-18c start
chkconfig oracle-xe-18c on

echo "..."
echo "... Write environment script for for ORACLE user"
echo "... "

echo "export ORACLE_SID=XE" > ${OSI_XE_ENV_SCRIPT}
echo "export ORAENV_ASK=NO" >> ${OSI_XE_ENV_SCRIPT}
echo "source /opt/oracle/product/18c/dbhomeXE/bin/oraenv" >> ${OSI_XE_ENV_SCRIPT}
chmod +x ${OSI_XE_ENV_SCRIPT}
chown oracle:oinstall ${OSI_XE_ENV_SCRIPT}

echo "... Append the new script to the .bash_profile of the oracle user"
if [[ -z $(grep "${OSI_XE_ENV_SCRIPT}" /home/oracle/.bash_profile) ]]; then
    echo "source ${OSI_XE_ENV_SCRIPT}" >> /home/oracle/.bash_profile
fi

# Perpare CA Wallet
${OSI_SCRIPT_DIR}/ca_wallet_from_java.sh

# Personal Adjustments to CDB
sqlplus -s sys/${OSI_XE_DEFAULT_PASSWORD}@//localhost/XE as sysdba << EOF
@${OSI_SCRIPT_DIR}/xe_post_cdb_adjust.sql
exit
EOF

# Personal Adjustments to PDB
sqlplus -s sys/${OSI_XE_DEFAULT_PASSWORD}@//localhost/${OSI_XE_DEFAULT_PDB} as sysdba << EOF
@${OSI_SCRIPT_DIR}/xe_post_pdb_adjust.sql
exit;
EOF

# Enable ORDS to connect to multiple PDBs
su -l oracle -c "${ORACLE_HOME}/perl/bin/perl -I ${ORACLE_HOME}/rdbms/admin ${ORACLE_HOME}/rdbms/admin/catcon.pl -l ${OSI_LOG_DIR} -b create_apex_pub -- --x'grant create session to apex_public_user identified by ${OSI_XE_DEFAULT_PASSWORD}'"
su -l oracle -c "${ORACLE_HOME}/perl/bin/perl -I ${ORACLE_HOME}/rdbms/admin ${ORACLE_HOME}/rdbms/admin/catcon.pl -l ${OSI_LOG_DIR} -b create_apex_list -- --x'grant create session to apex_listener identified by ${OSI_XE_DEFAULT_PASSWORD}'"
su -l oracle -c "${ORACLE_HOME}/perl/bin/perl -I ${ORACLE_HOME}/rdbms/admin ${ORACLE_HOME}/rdbms/admin/catcon.pl -l ${OSI_LOG_DIR} -b create_apex_rest_pub -- --x'grant create session to apex_rest_public_user identified by ${OSI_XE_DEFAULT_PASSWORD}'"

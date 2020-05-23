#!/bin/bash -e
#
#  ./scripts/ords_install.sh /stage/OracleXESimpleInstall/scripts autoInstall.params
#  $1 : Script Directory
#  $2 : Parameter File
#

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

# Test for ROOT user
f_is_root
# Load Parameter file
f_load_parameter_file $2
# Load XE environment
f_load_xe_env
f_set_osi_log_dir

# Do we have an ORDS zip
if [[ ! -f "$OSI_ORDS_ZIP" ]]
then
    # Not provided - try to find it
    OSI_ORDS_ZIP=$(find "$OSI_STAGE_DIR" -iname ords-*.zip)
    if [[ ! -f "$OSI_ORDS_ZIP" ]]
    then
        # Exit - we can not continue without a zip
        echo "ERROR - Unable to locate ORDS zip file."
        exit 1
    fi
fi

# Derive ORDS version from file name and verify it is not installed
l_ords_file=$(basename $OSI_ORDS_ZIP)
l_ords_file_base=${l_ords_file%.*}
l_ords_version=$(echo "${l_ords_file_base}" | grep -oP "\K[0-9.]*")

export ORDS_HOME=${ORACLE_BASE}/ords
l_ords_config_dir=${ORDS_HOME}/config
l_ords_doc_root_dir=${ORDS_HOME}/doc_root
l_ords_log_dir=${ORDS_HOME}/logs
l_ords_install_dir=${ORDS_HOME}/${l_ords_version}

# Display values being use
echo "... ORDS_HOME          = $ORDS_HOME"
echo "... OSI_LOG_DIR        = ${OSI_LOG_DIR}"
echo "... l_ords_install_dir = ${l_ords_install_dir}"
echo "... l_ords_config_dir  = ${l_ords_config_dir}"

#==============================================================================
#  Step 1: ORDS Unzip
#


mkdir -p "${l_ords_install_dir}"
mkdir -p "${l_ords_config_dir}/params"
mkdir -p "${l_ords_doc_root_dir}"
mkdir -p "${l_ords_log_dir}"
unzip -qo "${OSI_ORDS_ZIP}" -d "${l_ords_install_dir}"

# echo "... copy default configuration"
# mkdir -p ${l_ords_config_dir}/ords/standalone/doc_root

# Default html page for testing only
# echo "... copy default doc_root"
cp -rn ${OSI_SCRIPT_DIR}/../ords/doc_root ${ORDS_HOME}

# Parameter Files
echo "... Write ORDS installation properties file..."
cat > ${l_ords_config_dir}/params/ords_params.properties << EOF
db.hostname=localhost
db.port=1521
db.sid=xe
db.username=APEX_PUBLIC_USER
db.password=${OSI_XE_DEFAULT_PASSWORD}
migrate.apex.rest=false
plsql.gateway.add=true
rest.services.apex.add=true
rest.services.ords.add=true
schema.tablespace.default=SYSAUX
schema.tablespace.temp=TEMP
standalone.mode=false
standalone.http.port=8080
standalone.use.https=false
standalone.static.images=${ORACLE_BASE}/apex/images
user.apex.listener.password=${OSI_XE_DEFAULT_PASSWORD}
user.apex.restpublic.password=${OSI_XE_DEFAULT_PASSWORD}
user.public.password=${OSI_XE_DEFAULT_PASSWORD}
user.tablespace.default=SYSAUX
user.tablespace.temp=TEMP
bequeath.connect=true
EOF

cat > ${ORDS_HOME}/ords_service.properties << EOF
# Used by ords service for current versoin
ORDS_HOME=${ORDS_HOME}
ORDS_WAR_DIR=${l_ords_install_dir}
ORDS_USER=${OSI_ORDS_USER}
ORDS_JAVA="/usr/bin/java"
EOF

## Missing the standalone.properties
# standalone.static.images=/home/oracle/apex/images
# or needs correct docroot
#

#==============================================================================
#  Step 2: ORDS Install
#

echo "... Set permissions to allow service to run as user: $OSI_ORDS_USER"
chown -R ${OSI_ORDS_USER}:oinstall ${ORDS_HOME}


# echo "... burn the configdir into the ords.war"
# This is to cover the chance that someone starts the ORDS manually
# java -jar ${l_ords_install_dir}/ords.war configdir ${l_ords_config_dir}

## -DuseOracleHome=true use for 11g bequeath authentication
# su oracle -c java -jar -DuseOracleHome=true -Dconfig.dir=${l_ords_config_dir} $l_ords_install_dir/ords.war install simple --parameterFile ${l_ords_config_dir}/params/ords_params.properties


## Install ORDS into the CDB allowing support for multiple PDB connections
su -l oracle -c "source /home/oracle/XE.env; java -jar -DuseOracleHome=true -Dconfig.dir=${l_ords_config_dir} ${l_ords_install_dir}/ords.war install --parameterFile ${l_ords_config_dir}/params/ords_params.properties --logDir ${OSI_LOG_DIR}"

# if [[ $OSI_APEX_INSTALL = "Y" ]]
# then
#     echo "... copy apex web objects for use by standalone ORDS"
#     cp -r $ZIPS_PATH/working/apex/images $l_ords_install_dir/apex_images
# fi

## note - this is a combination of old and new startup technology....
## This is an area for improvement
echo "... System Configuration"
echo "... copy startup script to system"
cp $OSI_SCRIPT_DIR/../ords/init.d/ords /etc/init.d
echo "... update the systemctl registrations"
systemctl daemon-reload
echo "... enable ORDS to start on boot"
systemctl enable ords
echo "... start ORDS service"
service ords start

#!/bin/bash

##
## Functions used inside of scripts
##


# ===================================================================================
# Prints script usage information.
#
function f_functions_loaded () {
    echo "Functions previously loaded."
}
export -f f_functions_loaded

# ===================================================================================
# Prints script usage information.
#
function f_script_head () {
    echo "=="
    echo "== Script: $BASH_SOURCE"
    echo "=="
}
export -f f_script_head

# ===================================================================================
# Test for root using ID number
#   - could also be done using whoami
function f_is_root () {
    if [[ $EUID -ne 0 ]]; then
       echo "ERROR: This script must be run as root to execute installations"
       exit 1
    fi
}
export -f f_is_root

# ===================================================================================
# Used to verify and source the parameter file
#   - ToDo - do not re-load if already loaded....
function f_read_parameter_file () {
    local l_param_file
    l_param_file=$1
    if [[ -f "$l_param_file" ]]; then
        # use provided value
        source $l_param_file
    elif [[ -f "$OSI_BASE_DIR/autoInstall.params" ]]; then
        l_param_file="$OSI_BASE_DIR/autoInstall.params"
        source "$l_param_file"
    else
        # No file found - exit
        echo "Error: Unable to read provided or default parameter file: $l_param_file"
        exit 1
    fi
    OSI_PARAM_FILE=$l_param_file
    echo "... Loaded Parameter File: $OSI_PARAM_FILE"
}
export -f f_read_parameter_file

# ===================================================================================
# Prints checksum information.
#
function f_checksum () {
    # test if command exists
    # if command -v md5sum
    if [ -n "$(command -v md5sum)" ]
    then
        # This is too slow
        md5sum $1
    fi
}
export -f f_checksum


# ===================================================================================
# Test if parameter file needs to be loaded
#
function f_load_parameter_file () {
    # Load parameter file
    if [[ "$OSI_PARAMETERS_LOADED" == "Y" ]]
    then
        echo "... Parameters loaded = $OSI_PARAMETERS_LOADED"
    else
        f_read_parameter_file $1
    fi
}
export -f f_load_parameter_file


# ===================================================================================
# Test if parameter file needs to be loaded
#
function f_load_xe_env () {
    # Load XE Environment
    if [[ -z "$ORACLE_HOME" ]] && [[ -f "$OSI_XE_ENV_SCRIPT" ]]
    then
        source $OSI_XE_ENV_SCRIPT
        echo "... XE environment loaded"
    fi
}
export -f f_load_xe_env

# ===================================================================================
# Log directory
#
function f_set_osi_log_dir () {

    # Log Directory Logic
    if [[ -z "$OSI_LOG_DIR" ]]
    then
        if [[ -n "$OSI_BASE_DIR" ]] && [[ -d "$OSI_BASE_DIR" ]]
        then
            OSI_LOG_DIR="$OSI_BASE_DIR/logs"
        else
            # Base directory is empty or does not exist
            # Default to TMP
            OSI_LOG_DIR=/tmp/OSI_LOG_DIR
        fi

        if [[ ! -d "$OSI_LOG_DIR" ]]
        then
             mkdir -p "$OSI_LOG_DIR"
            # Change permissions on LOG directory for scripts run as ORACLE
            # This should only apply when ROOT is running the scripts
            chmod o+w "${OSI_LOG_DIR}"
        fi
    fi

    export OSI_LOG_DIR
    echo "... OSI_LOG_DIR = ${OSI_LOG_DIR}"
}
export -f f_set_osi_log_dir



# ===================================================================================
# bash logging
#
function f_start_logging () {

    l_log_file=$(date +%Y.%m.%d.%H.%M.%S).log
    export OSI_LOG_FILE="$OSI_LOG_DIR/$l_log_file"

    > "$OSI_LOG_FILE" || ( echo "ERROR: Unable to create log file ($OSI_LOG_FILE)."; exit 1; )

    exec >| >(tee -i "$OSI_LOG_FILE" )
    exec 2>&1
    echo "... Logging started in file ${OSI_LOG_FILE}"
}
export -f f_start_logging


echo "... Loaded functions script"

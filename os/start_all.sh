#!/bin/bash
# Script for automated startup
source /home/oracle/XE.env

# DB Default Overrides
export LISTENER_NAME=LISTENER

# General Vars
ORACLE_OWNER=oracle
CURRENT_USER=$(whoami)

# Commands
if [ -z "$SU" ];then SU=/bin/su; fi
if [ -z "$SQLPLUS" ];then SQLPLUS=$ORACLE_HOME/bin/sqlplus; fi
if [ -z "$LSNR" ];then LSNR=$ORACLE_HOME/bin/lsnrctl; fi
if [ -z "$GREP" ]; then GREP=/usr/bin/grep; fi

#
# Start Process
#

# Check if the DB is already started
pmon=`ps -ef | egrep pmon_$ORACLE_SID'\>' | $GREP -v grep`
if [ "$pmon" = "" ];
then

    echo "Starting Oracle Net Listener."
    echo "... start listener using $CURRENT_USER"
    if [ "$CURRENT_USER" = "root" ];
    then
        $SU -s /bin/bash $ORACLE_OWNER -c "$LSNR  start $LISTENER_NAME" > /dev/null 2>&1
    elif [ "$CURRENT_USER" = "$ORACLE_OWNER"  ]; then
        $LSNR start $LISTENER_NAME > /dev/null 2>&1
    else
        echo "ERROR: Script not designed to run as user $CURRENT_USER."
    fi

    RETVAL_LSNR=$?
    if [ $RETVAL_LSNR -eq 0 ]
    then
        echo "Oracle Net Listener started."
    fi

    echo "Starting Oracle Database instance $ORACLE_SID."
    ORA_SQL_CMD="$SQLPLUS -s /nolog << EOF
                                     connect / as sysdba
                                     startup
                                     alter pluggable database all open;
                                     exit;
                                     EOF"

    if [ "$CURRENT_USER" = "root" ];
    then
        $SU -s /bin/bash $ORACLE_OWNER -c "$ORA_SQL_CMD" > /dev/null 2>&1
    elif [ "$CURRENT_USER" = "$ORACLE_OWNER"  ]; then
        bash -c "$ORA_SQL_CMD"> /dev/null 2>&1
    else
        echo "ERROR: Script not designed to run as user $CURRENT_USER."
    fi


    RETVAL_DB=$?
    if [ $RETVAL_DB -eq 0 ]
    then
        ##ps -eaf | grep pmon | grep -v grep | awk '{print $2}' > /var/run/oracle-xe-18c.pid
        echo "Oracle Database instance $ORACLE_SID started."
    fi
else
    echo "The Oracle Database instance $ORACLE_SID is already started."
    exit 0
fi

echo "=================="
if [ $RETVAL_LSNR -eq 0 ] && [ $RETVAL_DB -eq 0 ]
then
    exit 0
else
    echo "Failed to start Oracle Net Listener using $ORACLE_HOME/bin/tnslsnr and Oracle Database using $ORACLE_HOME/bin/sqlplus."
    exit 1
fi

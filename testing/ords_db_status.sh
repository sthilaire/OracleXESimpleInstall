#!/bin/bash -e
#

source /home/oracle/XE.env
sqlplus sys/Welc0me1@XE as sysdba @ords_db_status.sql

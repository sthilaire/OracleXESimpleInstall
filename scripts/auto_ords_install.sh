#!/bin/bash 

[ -n "$AUTO_DEBUG" ] && set -x

echo "... Unzip ords in directory = "$ZIPS_PATH

unzip $ZIPS_PATH/ords.*.zip -d /u01/app/oracle/ords

echo "... copy default configuration"
#cp -r $THIS_DIR/ords/config /u01/app/oracle/ords
mkdir -p $THIS_DIR/ords/config/ords/standalone/doc_root
cp -r $THIS_DIR/ords/params /u01/app/oracle/ords

echo "... burn the configdir into the ords.war"
java -jar /u01/app/oracle/ords/ords.war configdir /u01/app/oracle/ords/config/
#echo "... first run install"
#java -jar /u01/app/oracle/ords/ords.war &


echo "... copy apex web objects for use by standalone ORDS"
cp -r /tmp/apex/images /u01/app/oracle/ords/config/ords/apex_images


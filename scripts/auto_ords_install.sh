#!/bin/bash 

[ -n "$AUTO_DEBUG" ] && set -x

echo "... Unzip ords in directory = "$ZIPS_PATH

unzip $ORDS_ZIP -d $ORDS_PATH

echo "... copy default configuration"
#cp -r $THIS_DIR/ords/config /u01/app/oracle/ords
mkdir -p $ORDS_PATH/config/ords/standalone/doc_root
cp -r $THIS_DIR/ords/params $ORDS_PATH

echo "*** TBD - SED the default parameter file to include passwords from param file ***"

echo "... burn the configdir into the ords.war"
java -jar $ORDS_PATH/ords.war configdir $ORDS_PATH/config/

if [[ "$APEX_UPGRADE" = "Y" ]]
then
    echo "... copy apex web objects for use by standalone ORDS"
    cp -r $ZIPS_PATH/working/apex/images $ORDS_PATH/apex_images
fi

echo "*** TBD - Set permissions to allow service to run ***"

echo "*** copy startup files ***"
echo "*** start service ***"




#!/bin/bash 

[ -n "$AUTO_DEBUG" ] && set -x

echo "... Unzip ords in directory = "$ZIPS_PATH

unzip -q $ORDS_ZIP -d $ORDS_PATH

echo "... copy default configuration"
#cp -r $THIS_DIR/ords/config /u01/app/oracle/ords
mkdir -p $ORDS_PATH/config/ords/standalone/doc_root
cp -r $THIS_DIR/ords/doc_root $ORDS_PATH/config/ords/standalone/
cp -r $THIS_DIR/ords/params $ORDS_PATH

echo "*** TBD - SED the default parameter file to include passwords from param file ***"

echo "... burn the configdir into the ords.war"
# This is to cover the chance that someone starts the ORDS manually
java -jar $ORDS_PATH/ords.war configdir $ORDS_PATH/config/

if [[ "$APEX_UPGRADE" = "Y" ]]
then
    echo "... copy apex web objects for use by standalone ORDS"
    cp -r $ZIPS_PATH/working/apex/images $ORDS_PATH/apex_images
fi

echo "... Set permissions to allow service to run as user: $ORDS_USER"
chown -R $ORDS_USER:dba $ORDS_PATH

echo "... copy startup script"
cp $THIS_DIR/ords/init.d/ords /etc/init.d

## note - this is a combination of old and new startup technology....
echo "... update the systemctl registrations"
systemctl daemon-reload
##echo "... enable ORDS to start on boot"
##systemctl enable ords
echo "... start ORDS service"
service ords start



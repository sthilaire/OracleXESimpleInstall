# OracleXESimpleInstall
Installation Automation scripts for Oracle XE, APEX, ORDS for OEL Linux

-- New version modified for XE 18c

# Who This Is For
Do you want to learn Oralce APEX?  Do you want to learn APEX administration? Do you want a playground you can try stuff out in without impacting others? Are you not an infrastructure wizard?

If these statements are true, this project may be for you.

This is a series of script automations for installing the primary technologies for a basic APEX stack without a lot of complexity.  It is intended to be easy to start with very little configuration or additional steps.


# Prerequisites
A Host - such as Oracle VM Virtual Box
http://www.oracle.com/technetwork/server-storage/virtualbox/downloads/index.html

On that host:
Download APEX
Download XE
Download ORDS
Download This project

# Fixed Assumptions
Database is run as user: oracle
Installation artifacts are located in the same directory, local to the installation
Installation Oracle base and database: /opt/oracle
Installation ORDS: /opt/oracle/ords/<version>/
Installation APEX: /opt/oracle/apex/<version>/



# Similar and More Advanced Projects
Much of these scripts are direct out of Oracle Documentation, but some of the details of these scripts have been shared by others.

Credit to others who have shared their knowledge and experience.

https://github.com/OraOpenSource/OXAR
https://ora-00001.blogspot.com/2015/06/installing-oracle-xe-ords-and-apex-on-centos-linux-part-zero.html
http://dsavenko.me/oracledb-apex-ords-tomcat-httpd-centos7-all-in-one-guide-introduction/
https://github.com/krisrice/docker-ords-sqlcl-apex
https://dbahelp2018.wordpress.com/install-oracle-xe-18c-using-virtualbox-part-1/


# OR - Built VMs
XE too limited for you?  OTN distributes pre built VMS with production versions of Oracle already installed.  I recommend the "Database App Development VM", but the "Upgrade and Migration Hands-on Lab" is also excellent with multiple Oracle versions.
http://www.oracle.com/technetwork/community/developer-vm/index.html

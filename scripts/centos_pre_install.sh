#!/bin/bash

## OS Adjustments

# Add the CentOS 7 EPEL repository
# https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-centos-7
sudo yum -y install epel-release
## Nginx
sudo yum -y install nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Adjust firewall for NGINX
## by default CentOS 7 comes with the firewall on except 2222
echo "=== Firewall adjustments"
firewall-cmd --list-all
firewall-cmd --permanent --zone=public --add-port=8080/tcp
firewall-cmd --permanent --zone=public --add-port=80/tcp
firewall-cmd --permanent --zone=public --add-port=443/tcp
firewall-cmd --reload
firewall-cmd --list-all
echo "=== Firewall adjustments complete"

# Configure NGINX
## There are a lot of options and assumptions here
## For now, this is going to be basic

## Create backup copy of the default index.html
BACKUP_DATE_TIME=$(date +%Y.%m.%d-%H.%M.%S)
cp /usr/share/nginx/html/index.html /usr/share/nginx/html/index.${BACKUP_DATE_TIME}.html
cp ../doc/index.html /usr/share/nginx/html/index.html

## Install JAVA
# (Improvement) Is this needed for CentOS7?
sudo yum -y install java-1.8.0-openjdk
# sudo yum install java-1.8.0-openjdk-devel

# Host file adjustment - allows cleaner install
# /etc/hosts

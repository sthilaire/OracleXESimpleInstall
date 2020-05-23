#!/bin/bash -e

echo "== Script: $BASH_SOURCE"

echo "..."
echo "... Create CA Wallet from Java certificate bundles."
echo "..."

## Create CA Wallet
# As is expected - java is a pain....
# Certificates located in:
# ls -la /etc/ssl/certs/
# - points to
# /etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt (complex)
# /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
# /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.212.b04-0.el7_6.x86_64/jre/lib/security/cacerts -> /etc/pki/java/cacerts
# ls -la /etc/pki/ca-trust/extracted/java/cacerts
JAVA_HOME=${ORACLE_HOME}/jdk
# JAVA_CERTS=${JAVA_HOME}/lib/security/cacerts

# Expected location from OS
# [root@centos ~]# rpm -qf /etc/pki/java/cacerts
# ca-certificates-2018.2.22-70.0.el7_5.noarch
JAVA_CERTS=/etc/pki/java/cacerts
if [[ -f ${JAVA_CERTS} ]]
then
    ls -l ${JAVA_CERTS}
else
    echo "ERROR: Unable to locate cacerts file - please review CA bundle (should have been installed with OS Java)"
    exit 1
fi

# List basic information about certs
${JAVA_HOME}/bin/keytool -list -keystore ${JAVA_CERTS} -storepass changeit | head -5

# To Get Count (not needed)
# $JAVA_HOME/bin/keytool -list -keystore ${JAVA_CERTS} -storepass changeit | grep trustedCertEntry | wc -l

# New Wallet Location - make a copy of the cert
OSI_CA_WALLET=${ORACLE_BASE}/ca-wallet
mkdir -p ${OSI_CA_WALLET}
cp ${JAVA_CERTS} ${OSI_CA_WALLET}
cd ${OSI_CA_WALLET}

# Locate orapki
which orapki

echo "..."
echo "... Create Empty PKCS12 Wallet with orapki..."
echo "..."
orapki wallet create -wallet . -pwd Oracle20##19 -auto_login

# ony needed for upgrade
# echo "..."
# echo "... Empty Wallet with orapki..."
# echo "..."
# orapki wallet remove -wallet . -trusted_cert_all -pwd Oracle20##19

echo "..."
echo "... Add trusted certs to  Empty PKCS12 Wallet"
echo "..."
orapki wallet jks_to_pkcs12 -wallet . -pwd Oracle20##19 -keystore cacerts -jkspwd changeit

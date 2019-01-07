#!/bin/bash

SERVERNAME=mysecuredserver
CITY=Stockholm
REGION=Stockholm
COUNTRY_CODE=SE
KEY_SIZE=4096

# If you don't have openssl and need a way to generate passwords, flip these two lines.
# LC_ALL=C tr -dc A-Za-z0-9 < /dev/urandom | head -c32 > password_server_$SERVERNAME
echo `openssl rand -base64 10` > password_server_$SERVERNAME

export PW=`cat password_server_$SERVERNAME`

# Create a self signed key pair root CA certificate.
keytool -genkeypair -v \
  -alias ${SERVERNAME}ca \
  -dname "CN=${SERVERNAME}ca, OU=$SERVERNAME Dev, O=$SERVERNAME, L=$CITY, ST=$REGION, C=$COUNTRY_CODE" \
  -keystore ${SERVERNAME}ca.jks \
  -keypass:env PW \
  -storepass:env PW \
  -keyalg RSA \
  -keysize $KEY_SIZE \
  -ext KeyUsage:critical="keyCertSign" \
  -ext BasicConstraints:critical="ca:true" \
  -validity 9999

# Export the CA public certificate as $SERVERNAMEca.crt so that it can be used in trust stores.
keytool -export -v \
  -alias ${SERVERNAME}ca \
  -file ${SERVERNAME}ca.crt \
  -keypass:env PW \
  -storepass:env PW \
  -keystore ${SERVERNAME}ca.jks \
  -rfc

# Create a server certificate, tied to $SERVERNAME
keytool -genkeypair -v \
  -alias $SERVERNAME \
  -dname "CN=$SERVERNAME, OU=$SERVERNAME Dev, O=$SERVERNAME, L=$CITY, ST=$REGION, C=$COUNTRY_CODE" \
  -keystore $SERVERNAME.jks \
  -keypass:env PW \
  -storepass:env PW \
  -keyalg RSA \
  -keysize $KEY_SIZE \
  -validity 385

# Create a certificate signing request for $SERVERNAME
keytool -certreq -v \
  -alias $SERVERNAME \
  -keypass:env PW \
  -storepass:env PW \
  -keystore $SERVERNAME.jks \
  -file $SERVERNAME.csr

# Tell CA to sign the $SERVERNAME certificate. 
# Technically, keyUsage should be digitalSignature for DHE or ECDHE, keyEncipherment for RSA.
keytool -gencert -v \
  -alias ${SERVERNAME}ca \
  -keypass:env PW \
  -storepass:env PW \
  -keystore ${SERVERNAME}ca.jks \
  -infile $SERVERNAME.csr \
  -outfile $SERVERNAME.crt \
  -ext KeyUsage:critical="digitalSignature,keyEncipherment" \
  -ext EKU="serverAuth" \
  -ext SAN="dns:$SERVERNAME,dns:localhost,ip:127.0.0.1" \
  -rfc

# Tell $SERVERNAME.jks it can trust $SERVERNAMEca as a signer.
keytool -import -v \
  -alias ${SERVERNAME}ca \
  -file ${SERVERNAME}ca.crt \
  -keystore $SERVERNAME.jks \
  -storetype JKS \
  -storepass:env PW \
  -noprompt

# Import the signed certificate back into $SERVERNAME.jks
keytool -import -v \
  -alias $SERVERNAME \
  -file $SERVERNAME.crt \
  -keystore $SERVERNAME.jks \
  -storetype JKS \
  -storepass:env PW

# List out the contents of $SERVERNAME.jks just to confirm it.
keytool -list -v \
  -keystore $SERVERNAME.jks \
  -storepass:env PW

export PW=""

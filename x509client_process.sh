#!/bin/bash

SERVERNAME=mysecuredserver
CITY=Stockholm
REGION=Stockholm
COUNTRY_CODE=SE
KEY_SIZE=4096

# If you don't have openssl and need a way to
# generate passwords, flip these two lines.
# LC_ALL=C tr -dc A-Za-z0-9 < /dev/urandom | head -c32 > password_client
echo `openssl rand -base64 10` > password_client

export CLIENTPW=`cat password_client`
export CAPW=`cat password_server_$SERVERNAME`

# Create a JKS keystore that trusts the CA, with the default password.
keytool -import -v \
  -alias $SERVERNAME\ca \
  -file $SERVERNAME\ca.crt \
  -keypass:env CLIENTPW \
  -storepass:env CLIENTPW \
  -keystore client.jks \
  -noprompt

# Create another key pair that will act as the client.
keytool -genkeypair -v \
  -alias client \
  -keystore client.jks \
  -dname "CN=client, OU=$SERVERNAME Dev, O=$SERVERNAME, L=$CITY, ST=$REGION, C=$COUNTRY_CODE" \
  -keypass:env CLIENTPW \
  -storepass:env CLIENTPW \
  -keyalg RSA \
  -keysize $KEY_SIZE

# Create a certificate signing request from the client certificate.
keytool -certreq -v \
  -alias client \
  -keypass:env CLIENTPW \
  -storepass:env CLIENTPW \
  -keystore client.jks \
  -file client.csr

# Make the CA create a certificate chain saying that client is signed by the CA.
keytool -gencert -v \
  -alias $SERVERNAME\ca \
  -keypass:env CAPW \
  -storepass:env CAPW \
  -keystore $SERVERNAME\ca.jks \
  -infile client.csr \
  -outfile client.crt \
  -ext EKU="clientAuth" \
  -rfc

# Import the signed certificate back into client.jks.  This is important, as JSSE won't send a client
# certificate if it can't find one signed by the ca presented in the CertificateRequest.
keytool -import -v \
  -alias client \
  -file client.crt \
  -keystore client.jks \
  -storetype JKS \
  -storepass:env CLIENTPW

# List out the contents of client.jks just to confirm it.
keytool -list -v \
  -keystore client.jks \
  -storepass:env CLIENTPW

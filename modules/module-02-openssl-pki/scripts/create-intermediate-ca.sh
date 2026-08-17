#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

mkdir -p "$INTERMEDIATE_DIR"/{certs,private,csr,newcerts,crl}

touch "$INTERMEDIATE_DIR/index.txt"

echo 2000 > "$INTERMEDIATE_DIR/serial"

openssl genpkey \
    -algorithm RSA \
    -out "$INTERMEDIATE_DIR/private/intermediate-ca.key" \
    -pkeyopt rsa_keygen_bits:"$RSA_BITS"

chmod 600 "$INTERMEDIATE_DIR/private/intermediate-ca.key"

openssl req \
    -new \
    -key "$INTERMEDIATE_DIR/private/intermediate-ca.key" \
    -out "$INTERMEDIATE_DIR/csr/intermediate-ca.csr" \
    -subj "/C=FR/ST=Ile-de-France/L=Paris/O=Merland PKI Automatisation/OU=Merland Intermediate CA/CN=Merland Intermediate CA/emailAddress=merlandbafouetila045@gmail.com"

openssl x509 \
    -req \
    -in "$INTERMEDIATE_DIR/csr/intermediate-ca.csr" \
    -CA "$ROOT_DIR/certs/root-ca.crt" \
    -CAkey "$ROOT_DIR/private/root-ca.key" \
    -CAcreateserial \
    -out "$INTERMEDIATE_DIR/certs/intermediate-ca.crt" \
    -days "$DAYS_INTERMEDIATE" \
    -sha256 \
    -extfile "$SCRIPT_DIR/intermediate-ca.ext"

cat \
    "$INTERMEDIATE_DIR/certs/intermediate-ca.crt" \
    "$ROOT_DIR/certs/root-ca.crt" \
    > "$INTERMEDIATE_DIR/certs/ca-chain.crt"

echo "Intermediate CA créée."
echo "Chaîne de confiance créée."

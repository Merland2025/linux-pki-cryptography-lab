#!/bin/bash

set -e

source config.sh

create_directories() {

    mkdir -p "$ROOT_DIR"/{certs,private,csr,newcerts,crl}

    touch "$ROOT_DIR/index.txt"

    echo 1000 > "$ROOT_DIR/serial"

}

generate_key() {

    openssl genpkey \
        -algorithm RSA \
        -out "$ROOT_DIR/private/root-ca.key" \
        -pkeyopt rsa_keygen_bits:$RSA_BITS

    chmod 600 "$ROOT_DIR/private/root-ca.key"

}

generate_certificate() {

    openssl req \
        -new \
        -x509 \
        -days $DAYS_ROOT \
        -key "$ROOT_DIR/private/root-ca.key" \
        -out "$ROOT_DIR/certs/root-ca.crt"

}

create_directories

generate_key

generate_certificate

echo "Root CA créée."

#!/bin/bash

set -e

echo "[RSA] Génération de la clé"

openssl genpkey -algorithm RSA -out rsa.key -pkeyopt rsa_keygen_bits:2048

echo "OpenSSL RSA Test" > message.txt

echo "[RSA] Signature"

openssl dgst -sha256 -sign rsa.key -out rsa.sig message.txt

echo "[RSA] Vérification"

openssl dgst -sha256 \
    -verify <(openssl pkey -in rsa.key -pubout) \
    -signature rsa.sig \
    message.txt

echo "[RSA] OK"

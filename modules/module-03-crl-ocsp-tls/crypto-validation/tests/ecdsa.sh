#!/bin/bash

set -e

openssl genpkey \
    -algorithm EC \
    -pkeyopt ec_paramgen_curve:P-256 \
    -out ecdsa.key

echo "ECDSA Test" > message.txt

openssl dgst -sha256 -sign ecdsa.key -out ecdsa.sig message.txt

openssl dgst -sha256 \
    -verify <(openssl pkey -in ecdsa.key -pubout) \
    -signature ecdsa.sig \
    message.txt

echo "[ECDSA] OK"

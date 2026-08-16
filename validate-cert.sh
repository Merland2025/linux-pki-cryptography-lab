#!/bin/bash

CERT="$1"

echo "=== Sujet ==="

openssl x509 -noout -subject -in "$CERT"

echo "=== Émetteur ==="

openssl x509 -noout -issuer -in "$CERT"

echo "=== Dates ==="

openssl x509 -noout -dates -in "$CERT"

echo "=== SAN ==="

openssl x509 -text -noout -in "$CERT" | grep -A1 "Subject Alternative Name"

echo "=== Empreinte SHA256 ==="

openssl x509 -noout -fingerprint -sha256 -in "$CERT"

echo "=== Vérification ==="

openssl verify \
-CAfile intermediate-ca/certs/ca-chain.crt \
"$CERT"

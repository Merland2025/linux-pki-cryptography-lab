#!/bin/bash

set -e

CERT="$1"

if [ -z "$CERT" ]; then
    echo "Usage: $0 <certificate>"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CA_CHAIN="$MODULE_DIR/intermediate-ca/certs/ca-chain.crt"

echo "=== Sujet ==="
openssl x509 -noout -subject -in "$CERT"

echo "=== Émetteur ==="
openssl x509 -noout -issuer -in "$CERT"

echo "=== Dates ==="
openssl x509 -noout -dates -in "$CERT"

echo "=== SAN ==="
openssl x509 -text -noout -in "$CERT" |
    grep -A1 "Subject Alternative Name" || true

echo "=== Empreinte SHA256 ==="
openssl x509 -noout -fingerprint -sha256 -in "$CERT"

echo "=== Vérification ==="
openssl verify \
    -CAfile "$CA_CHAIN" \
    "$CERT"

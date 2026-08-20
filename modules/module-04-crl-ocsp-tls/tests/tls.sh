#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

ROOT_CERT="$MODULE_DIR/tls/root-ca/certs/root-ca.crt"
INTERMEDIATE_CERT="$MODULE_DIR/tls/intermediate-ca/certs/intermediate-ca.crt"
CHAIN="$MODULE_DIR/tls/intermediate-ca/certs/ca-chain.crt"
SERVER_CERT="$MODULE_DIR/tls/server/certs/server.crt"
SERVER_KEY="$MODULE_DIR/tls/server/private/server.key"

echo "[TLS] Vérification des fichiers"

test -f "$ROOT_CERT"
test -f "$INTERMEDIATE_CERT"
test -f "$CHAIN"
test -f "$SERVER_CERT"
test -f "$SERVER_KEY"

echo "[TLS] Vérification de la chaîne"

openssl verify \
    -CAfile "$CHAIN" \
    "$SERVER_CERT"

echo "[TLS] Vérification du certificat"

openssl x509 \
    -in "$SERVER_CERT" \
    -noout \
    -subject \
    -issuer \
    -dates

echo "[TLS] Vérification du SAN"

openssl x509 \
    -in "$SERVER_CERT" \
    -noout \
    -ext subjectAltName |
    grep -q "DNS:web.example.com"

echo "[TLS] Vérification de la clé privée"

openssl pkey \
    -in "$SERVER_KEY" \
    -check \
    -noout

echo "[TLS] OK"

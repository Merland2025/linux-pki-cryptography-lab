#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PKI_DIR="$BASE_DIR/pki"

ROOT_CERT="$PKI_DIR/root-ca.crt"
SERVER_CERT="$PKI_DIR/server.crt"
SERVER_KEY="$PKI_DIR/server.key"

echo "[TLS] Vérification du certificat serveur"

openssl verify \
    -CAfile "$ROOT_CERT" \
    "$SERVER_CERT"

echo "[TLS] Vérification du certificat"

openssl x509 \
    -in "$SERVER_CERT" \
    -noout \
    -subject \
    -issuer \
    -dates

echo "[TLS] Vérification de la clé privée"

openssl pkey \
    -in "$SERVER_KEY" \
    -check \
    -noout

echo "[TLS] OK"

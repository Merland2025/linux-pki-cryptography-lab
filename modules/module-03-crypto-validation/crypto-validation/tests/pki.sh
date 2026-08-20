#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PKI_DIR="$BASE_DIR/pki"

ROOT_KEY="$PKI_DIR/root-ca.key"
ROOT_CERT="$PKI_DIR/root-ca.crt"
SERVER_KEY="$PKI_DIR/server.key"
SERVER_CSR="$PKI_DIR/server.csr"
SERVER_CERT="$PKI_DIR/server.crt"

mkdir -p "$PKI_DIR"

echo "[PKI] Création de la CA de test"

openssl req \
    -new \
    -x509 \
    -nodes \
    -newkey rsa:2048 \
    -keyout "$ROOT_KEY" \
    -out "$ROOT_CERT" \
    -days 365 \
    -subj "/C=FR/O=PKI Automation/CN=Module 03 Test Root CA"

chmod 600 "$ROOT_KEY"

echo "[PKI] Création de la clé serveur"

openssl genpkey \
    -algorithm RSA \
    -out "$SERVER_KEY" \
    -pkeyopt rsa_keygen_bits:2048

chmod 600 "$SERVER_KEY"

echo "[PKI] Création du CSR serveur"

openssl req \
    -new \
    -key "$SERVER_KEY" \
    -out "$SERVER_CSR" \
    -subj "/C=FR/O=PKI Automation/CN=localhost"

echo "[PKI] Signature du certificat serveur"

openssl x509 \
    -req \
    -in "$SERVER_CSR" \
    -CA "$ROOT_CERT" \
    -CAkey "$ROOT_KEY" \
    -CAcreateserial \
    -out "$SERVER_CERT" \
    -days 365 \
    -sha256

echo "[PKI] Vérification de la chaîne"

openssl verify \
    -CAfile "$ROOT_CERT" \
    "$SERVER_CERT"

echo "[PKI] OK"

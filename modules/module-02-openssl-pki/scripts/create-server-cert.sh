#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

SERVER_NAME="$1"

error() {
    echo "ERREUR: $1" >&2
    exit 1
}

[ -z "$SERVER_NAME" ] && error "Nom du serveur requis"

BASE_DIR="$MODULE_DIR"

PRIVATE_DIR="$BASE_DIR/private"
CSR_DIR="$BASE_DIR/csr"
CERTS_DIR="$BASE_DIR/certs"

mkdir -p "$PRIVATE_DIR" "$CSR_DIR" "$CERTS_DIR"

KEY="$PRIVATE_DIR/$SERVER_NAME.key"
CSR="$CSR_DIR/$SERVER_NAME.csr"
CERT="$CERTS_DIR/$SERVER_NAME.crt"
SAN="$BASE_DIR/san.cnf"

echo "[1/5] Génération de la clé privée..."

openssl genrsa \
    -out "$KEY" \
    2048

chmod 600 "$KEY"

echo "[2/5] Génération du CSR..."

openssl req \
    -new \
    -key "$KEY" \
    -out "$CSR" \
    -subj "/C=FR/ST=Ile-de-France/L=Paris/O=Merland PKI Automatisation/OU=Server/CN=$SERVER_NAME"

echo "[3/5] Création de l'extension SAN..."

cat > "$SAN" <<SANEOF
subjectAltName=DNS:$SERVER_NAME
basicConstraints=critical,CA:false
keyUsage=critical,digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
SANEOF

echo "[4/5] Signature du certificat..."

openssl x509 \
    -req \
    -in "$CSR" \
    -CA "$INTERMEDIATE_DIR/certs/intermediate-ca.crt" \
    -CAkey "$INTERMEDIATE_DIR/private/intermediate-ca.key" \
    -CAcreateserial \
    -out "$CERT" \
    -days 365 \
    -sha256 \
    -extfile "$SAN"

echo "[5/5] Vérification..."

openssl verify \
    -CAfile "$INTERMEDIATE_DIR/certs/ca-chain.crt" \
    "$CERT"

echo
echo "Certificat créé : $CERT"
echo "Clé privée      : $KEY"
echo "CSR             : $CSR"

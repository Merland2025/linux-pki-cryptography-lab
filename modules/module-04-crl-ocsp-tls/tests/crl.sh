#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CRL="$MODULE_DIR/crl/intermediate-ca.crl"
CA_CERT="$MODULE_DIR/tls/intermediate-ca/certs/intermediate-ca.crt"
CHAIN="$MODULE_DIR/tls/intermediate-ca/certs/ca-chain.crt"
SERVER_CERT="$MODULE_DIR/tls/server/certs/server.crt"

echo "[CRL] Vérification des fichiers"

test -f "$CRL"
test -f "$CA_CERT"
test -f "$CHAIN"
test -f "$SERVER_CERT"

echo "[CRL] Vérification de la signature"

openssl crl \
    -in "$CRL" \
    -CAfile "$CA_CERT" \
    -noout

echo "[CRL] Recherche du certificat révoqué"

SERIAL="$(
    openssl x509 \
        -in "$SERVER_CERT" \
        -noout \
        -serial |
        cut -d= -f2
)"

echo "[CRL] Serial : $SERIAL"

if ! openssl crl \
    -in "$CRL" \
    -text \
    -noout |
    grep -qi "$SERIAL"; then

    echo "[CRL] ERREUR : certificat serveur absent de la CRL"
    exit 1
fi

echo "[CRL] Vérification de révocation"

if openssl verify \
    -CAfile "$CHAIN" \
    -CRLfile "$CRL" \
    -crl_check \
    "$SERVER_CERT"; then

    echo "[CRL] ERREUR : le certificat révoqué a été accepté"
    exit 1
else
    echo "[CRL] OK : le certificat révoqué est correctement refusé"
fi

echo "[CRL] OK"

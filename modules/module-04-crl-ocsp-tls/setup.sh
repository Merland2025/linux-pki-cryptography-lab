#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TLS_DIR="$SCRIPT_DIR/tls"
CRL_DIR="$SCRIPT_DIR/crl"
OCSP_DIR="$SCRIPT_DIR/ocsp"

ROOT_DIR="$TLS_DIR/root-ca"
INT_DIR="$TLS_DIR/intermediate-ca"
SERVER_DIR="$TLS_DIR/server"

echo "========================================"
echo " MODULE 04 - INITIALISATION PKI LOCALE"
echo "========================================"

# ============================================================
# Nettoyage des anciennes données générées du module 04
# ============================================================

rm -rf \
    "$ROOT_DIR" \
    "$INT_DIR" \
    "$SERVER_DIR" \
    "$CRL_DIR" \
    "$OCSP_DIR"

mkdir -p \
    "$ROOT_DIR"/{certs,private,newcerts,crl} \
    "$INT_DIR"/{certs,private,csr,newcerts,crl} \
    "$SERVER_DIR"/{certs,private,csr} \
    "$CRL_DIR"/{ca,newcerts} \
    "$OCSP_DIR"

chmod 700 \
    "$ROOT_DIR/private" \
    "$INT_DIR/private" \
    "$SERVER_DIR/private"

# ============================================================
# ROOT CA
# ============================================================

echo "[SETUP] Génération Root CA"

touch "$ROOT_DIR/index.txt"
echo 1000 > "$ROOT_DIR/serial"
echo 1000 > "$ROOT_DIR/crlnumber"

openssl genrsa \
    -out "$ROOT_DIR/private/root-ca.key" \
    4096

openssl req \
    -x509 \
    -new \
    -sha256 \
    -days 3650 \
    -key "$ROOT_DIR/private/root-ca.key" \
    -out "$ROOT_DIR/certs/root-ca.crt" \
    -subj "/C=FR/ST=Ile-de-France/L=Paris/O=Module 04 PKI/OU=Root CA/CN=Module 04 Root CA" \
    -addext "basicConstraints=critical,CA:TRUE,pathlen:1" \
    -addext "keyUsage=critical,keyCertSign,cRLSign" \
    -addext "subjectKeyIdentifier=hash"

# ============================================================
# INTERMEDIATE CA
# ============================================================

echo "[SETUP] Génération Intermediate CA"

touch "$INT_DIR/index.txt"
echo 1000 > "$INT_DIR/serial"
echo 1000 > "$INT_DIR/crlnumber"

openssl genrsa \
    -out "$INT_DIR/private/intermediate-ca.key" \
    4096

openssl req \
    -new \
    -sha256 \
    -key "$INT_DIR/private/intermediate-ca.key" \
    -out "$INT_DIR/csr/intermediate-ca.csr" \
    -subj "/C=FR/ST=Ile-de-France/L=Paris/O=Module 04 PKI/OU=Intermediate CA/CN=Module 04 Intermediate CA"

cat > "$INT_DIR/intermediate.ext" <<'EXT'
basicConstraints=critical,CA:TRUE,pathlen:0
keyUsage=critical,keyCertSign,cRLSign
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
EXT

openssl x509 \
    -req \
    -sha256 \
    -days 1825 \
    -in "$INT_DIR/csr/intermediate-ca.csr" \
    -CA "$ROOT_DIR/certs/root-ca.crt" \
    -CAkey "$ROOT_DIR/private/root-ca.key" \
    -CAcreateserial \
    -out "$INT_DIR/certs/intermediate-ca.crt" \
    -extfile "$INT_DIR/intermediate.ext"

cat \
    "$INT_DIR/certs/intermediate-ca.crt" \
    "$ROOT_DIR/certs/root-ca.crt" \
    > "$INT_DIR/certs/ca-chain.crt"

# ============================================================
# CONFIGURATION OPENSSL DE L'INTERMEDIATE CA
# ============================================================

echo "[SETUP] Configuration de l'Intermediate CA"

cat > "$INT_DIR/openssl.cnf" <<CFG
[ ca ]
default_ca = CA_default

[ CA_default ]

dir               = $INT_DIR
database          = \$dir/index.txt
new_certs_dir     = \$dir/newcerts

certificate       = \$dir/certs/intermediate-ca.crt
private_key       = \$dir/private/intermediate-ca.key

serial            = \$dir/serial
crlnumber         = \$dir/crlnumber

default_md        = sha256
default_days      = 825
default_crl_days  = 30

policy            = policy_loose

x509_extensions   = server_cert

[ policy_loose ]

countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ server_cert ]

basicConstraints        = critical,CA:FALSE
keyUsage                = critical,digitalSignature,keyEncipherment
extendedKeyUsage        = serverAuth
subjectAltName          = DNS:web.example.com
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid,issuer
CFG

# ============================================================
# CERTIFICAT SERVEUR
# ============================================================

echo "[SETUP] Génération certificat serveur"

openssl genrsa \
    -out "$SERVER_DIR/private/server.key" \
    2048

openssl req \
    -new \
    -sha256 \
    -key "$SERVER_DIR/private/server.key" \
    -out "$SERVER_DIR/csr/server.csr" \
    -subj "/C=FR/ST=Ile-de-France/L=Paris/O=Module 04 PKI/OU=Server/CN=web.example.com"

openssl ca \
    -batch \
    -config "$INT_DIR/openssl.cnf" \
    -extensions server_cert \
    -in "$SERVER_DIR/csr/server.csr" \
    -out "$SERVER_DIR/certs/server.crt"

cat \
    "$SERVER_DIR/certs/server.crt" \
    "$INT_DIR/certs/intermediate-ca.crt" \
    > "$SERVER_DIR/certs/server-chain.crt"

# ============================================================
# CERTIFICAT OCSP RESPONDER
# ============================================================

echo "[SETUP] Génération certificat OCSP responder"

openssl genrsa \
    -out "$OCSP_DIR/ocsp.key" \
    2048

openssl req \
    -new \
    -sha256 \
    -key "$OCSP_DIR/ocsp.key" \
    -out "$OCSP_DIR/ocsp.csr" \
    -subj "/C=FR/ST=Ile-de-France/L=Paris/O=Module 04 PKI/OU=OCSP/CN=Module 04 OCSP Responder"

cat > "$OCSP_DIR/ocsp.ext" <<'EXT'
basicConstraints=critical,CA:FALSE
keyUsage=critical,digitalSignature
extendedKeyUsage=critical,OCSPSigning
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
EXT

openssl x509 \
    -req \
    -sha256 \
    -days 825 \
    -in "$OCSP_DIR/ocsp.csr" \
    -CA "$INT_DIR/certs/intermediate-ca.crt" \
    -CAkey "$INT_DIR/private/intermediate-ca.key" \
    -CAcreateserial \
    -out "$OCSP_DIR/ocsp.crt" \
    -extfile "$OCSP_DIR/ocsp.ext"

# ============================================================
# RÉVOCATION DU CERTIFICAT SERVEUR
# ============================================================

echo "[SETUP] Révocation du certificat serveur"

openssl ca \
    -config "$INT_DIR/openssl.cnf" \
    -revoke "$SERVER_DIR/certs/server.crt"

# ============================================================
# CRL
# ============================================================

echo "[SETUP] Génération de la CRL"

openssl ca \
    -config "$INT_DIR/openssl.cnf" \
    -gencrl \
    -out "$CRL_DIR/intermediate-ca.crl"

cp \
    "$CRL_DIR/intermediate-ca.crl" \
    "$CRL_DIR/ca/intermediate-ca.crl"

# ============================================================
# COPIES PRATIQUES POUR LES TESTS TLS
# ============================================================

cp \
    "$ROOT_DIR/certs/root-ca.crt" \
    "$TLS_DIR/root-ca.crt"

cp \
    "$INT_DIR/certs/intermediate-ca.crt" \
    "$TLS_DIR/intermediate-ca.crt"

cp \
    "$INT_DIR/certs/ca-chain.crt" \
    "$TLS_DIR/ca-chain.crt"

cp \
    "$SERVER_DIR/certs/server.crt" \
    "$TLS_DIR/server.crt"

cp \
    "$SERVER_DIR/private/server.key" \
    "$TLS_DIR/server.key"

chmod 600 \
    "$ROOT_DIR/private/root-ca.key" \
    "$INT_DIR/private/intermediate-ca.key" \
    "$SERVER_DIR/private/server.key" \
    "$OCSP_DIR/ocsp.key"

echo
echo "========================================"
echo "[SETUP] MODULE 04 INITIALISÉ"
echo "========================================"
echo
echo "Root CA       : $ROOT_DIR/certs/root-ca.crt"
echo "Intermediate  : $INT_DIR/certs/intermediate-ca.crt"
echo "Server        : $SERVER_DIR/certs/server.crt"
echo "CRL           : $CRL_DIR/intermediate-ca.crl"
echo "OCSP cert     : $OCSP_DIR/ocsp.crt"
echo "OCSP key      : $OCSP_DIR/ocsp.key"
echo
echo "[SETUP] Le certificat serveur est révoqué."
echo "========================================"

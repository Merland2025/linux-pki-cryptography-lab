#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

OCSP_CERT="$MODULE_DIR/ocsp/ocsp.crt"
OCSP_KEY="$MODULE_DIR/ocsp/ocsp.key"

ISSUER="$MODULE_DIR/tls/intermediate-ca/certs/intermediate-ca.crt"
CA_CHAIN="$MODULE_DIR/tls/intermediate-ca/certs/ca-chain.crt"
CERT="$MODULE_DIR/tls/server/certs/server.crt"
INDEX="$MODULE_DIR/tls/intermediate-ca/index.txt"

PORT=2560

PIDFILE="/tmp/module-04-ocsp.pid"
LOGFILE="/tmp/module-04-ocsp.log"
OCSP_RESPONSE="/tmp/module-04-ocsp-response.der"

cleanup() {
    if [ -f "$PIDFILE" ]; then
        PID="$(cat "$PIDFILE" 2>/dev/null || true)"

        if [ -n "${PID:-}" ] && kill -0 "$PID" 2>/dev/null; then
            kill "$PID" 2>/dev/null || true
            sleep 1
        fi

        rm -f "$PIDFILE"
    fi
}

trap cleanup EXIT

echo "===== OCSP ====="

echo "[OCSP] Vérification des fichiers"

test -f "$OCSP_CERT"
test -f "$OCSP_KEY"
test -f "$ISSUER"
test -f "$CA_CHAIN"
test -f "$CERT"
test -f "$INDEX"

echo "[OCSP] Vérification de la clé"

openssl pkey \
    -in "$OCSP_KEY" \
    -check \
    -noout

echo "[OCSP] Vérification du certificat OCSP"

openssl verify \
    -CAfile "$CA_CHAIN" \
    "$OCSP_CERT"

echo "[OCSP] Vérification OCSPSigning"

openssl x509 \
    -in "$OCSP_CERT" \
    -noout \
    -text |
grep -A2 "Extended Key Usage" |
grep -q "OCSP Signing"

echo "[OCSP] Démarrage du répondeur OCSP"

cleanup

openssl ocsp \
    -index "$INDEX" \
    -rsigner "$OCSP_CERT" \
    -rkey "$OCSP_KEY" \
    -CA "$ISSUER" \
    -port "$PORT" \
    >"$LOGFILE" 2>&1 &

echo $! > "$PIDFILE"

sleep 2

PID="$(cat "$PIDFILE")"

if ! kill -0 "$PID" 2>/dev/null; then
    echo "[OCSP] ERREUR : le serveur OCSP n'a pas démarré"
    cat "$LOGFILE"
    exit 1
fi

echo "[OCSP] Serveur démarré sur le port $PORT"

echo "[OCSP] Interrogation du certificat serveur"

openssl ocsp \
    -issuer "$ISSUER" \
    -cert "$CERT" \
    -CAfile "$CA_CHAIN" \
    -url "http://127.0.0.1:$PORT" \
    -respout "$OCSP_RESPONSE" \
    -resp_text

echo "[OCSP] Vérification de la réponse"

test -s "$OCSP_RESPONSE"

openssl ocsp \
    -respin "$OCSP_RESPONSE" \
    -text \
    -noverify |
grep -q "Cert Status: revoked"

echo "[OCSP] OK : le certificat serveur est correctement indiqué comme révoqué"
echo "[OCSP] OK"

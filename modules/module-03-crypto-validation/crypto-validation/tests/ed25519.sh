#!/bin/bash

set -euo pipefail

KEY="ed25519.key"
PUBLIC_KEY="ed25519-public.key"
MESSAGE="message.txt"
SIGNATURE="ed25519.sig"

echo "[Ed25519] Génération de la clé..."

openssl genpkey \
    -algorithm Ed25519 \
    -out "$KEY"

echo "[Ed25519] Extraction de la clé publique..."

openssl pkey \
    -in "$KEY" \
    -pubout \
    -out "$PUBLIC_KEY"

echo "[Ed25519] Création du message..."

printf '%s\n' "Ed25519 Test" > "$MESSAGE"

echo "[Ed25519] Signature..."

openssl pkeyutl \
    -sign \
    -rawin \
    -inkey "$KEY" \
    -in "$MESSAGE" \
    -out "$SIGNATURE"

echo "[Ed25519] Vérification..."

openssl pkeyutl \
    -verify \
    -rawin \
    -pubin \
    -inkey "$PUBLIC_KEY" \
    -sigfile "$SIGNATURE" \
    -in "$MESSAGE"

echo "[Ed25519] OK"

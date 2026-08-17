#!/bin/bash

set -e

MODULE=/usr/lib/softhsm/libsofthsm2.so
PIN=987654

echo "[PKCS11] Vérification du module"

[ -f "$MODULE" ]

echo "[PKCS11] Liste des objets"

pkcs11-tool \
    --module "$MODULE" \
    --login \
    --pin "$PIN" \
    --list-objects

echo "[PKCS11] OK"

#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TESTS=(
    crl.sh
    ocsp.sh
    tls.sh
)

PASS=0
FAIL=0

echo "========================================"
echo "   MODULE 04 - CRL / OCSP / TLS"
echo "========================================"

for t in "${TESTS[@]}"; do
    echo
    echo "===== $t ====="

    if bash "$SCRIPT_DIR/$t"; then
        PASS=$((PASS + 1))
        echo "[RUN_ALL] $t : PASS"
    else
        FAIL=$((FAIL + 1))
        echo "[RUN_ALL] $t : FAIL"
    fi
done

echo
echo "========================================"
echo "          RÉSULTAT FINAL"
echo "========================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "========================================"

if [ "$FAIL" -ne 0 ]; then
    echo "[RUN_ALL] AU MOINS UN TEST A ÉCHOUÉ"
    exit 1
fi

echo "[RUN_ALL] TOUS LES TESTS SONT PASSÉS"

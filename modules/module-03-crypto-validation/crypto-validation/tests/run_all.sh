#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TESTS=(
    rsa.sh
    ecdsa.sh
    ed25519.sh
    pkcs11.sh
    pki.sh
)

PASS=0
FAIL=0

echo "========================================"
echo "   MODULE 03 - CRYPTO VALIDATION"
echo "========================================"

for t in "${TESTS[@]}"
do
    echo
    echo "===== $t ====="

    if bash "$SCRIPT_DIR/$t"
    then
        echo "[RUN_ALL] $t : PASS"
        PASS=$((PASS + 1))
    else
        echo "[RUN_ALL] $t : FAIL"
        FAIL=$((FAIL + 1))
    fi
done

echo
echo "========================================"
echo "          RÉSULTAT FINAL"
echo "========================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "========================================"

if [ "$FAIL" -eq 0 ]; then
    echo "[RUN_ALL] TOUS LES TESTS SONT PASSÉS"
    exit 0
else
    echo "[RUN_ALL] AU MOINS UN TEST A ÉCHOUÉ"
    exit 1
fi

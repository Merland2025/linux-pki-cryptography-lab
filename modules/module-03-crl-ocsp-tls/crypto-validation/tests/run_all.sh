#!/bin/bash

set -e

TESTS=(
    rsa.sh
    ecdsa.sh
    ed25519.sh
    pkcs11.sh
    pki.sh
    tls.sh
)

PASS=0

FAIL=0

for t in "${TESTS[@]}"

do

    echo

    echo "===== $t ====="

    if ./tests/$t

    then

        PASS=$((PASS+1))

    else

        FAIL=$((FAIL+1))

    fi

done

echo

echo "PASS : $PASS"

echo "FAIL : $FAIL"

[ "$FAIL" -eq 0 ]

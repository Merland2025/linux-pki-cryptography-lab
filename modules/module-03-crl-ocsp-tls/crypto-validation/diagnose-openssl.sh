#!/bin/bash

echo "===== OPENSSL ====="
openssl version -a

echo
echo "===== PROVIDERS ====="
openssl list -providers

echo
echo "===== SIGNATURES ====="
openssl list -signature-algorithms

echo
echo "===== DIGESTS ====="
openssl list -digest-algorithms

echo
echo "===== CONFIG ====="
echo "OPENSSL_CONF=$OPENSSL_CONF"

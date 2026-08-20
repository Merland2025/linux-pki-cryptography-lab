#!/bin/bash

set -euo pipefail

echo "[BENCH] RSA"

openssl speed rsa2048

echo "[BENCH] AES"

openssl speed -evp aes-256-gcm

echo "[BENCH] SHA256"

openssl speed sha256

echo "[BENCH] OK"

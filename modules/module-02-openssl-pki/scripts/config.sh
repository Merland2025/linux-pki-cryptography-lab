#!/bin/bash

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ROOT_DIR="$MODULE_DIR/root-ca"
INTERMEDIATE_DIR="$MODULE_DIR/intermediate-ca"

DAYS_ROOT=3650
DAYS_INTERMEDIATE=1825

RSA_BITS=4096

#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/create-root-ca.sh"
"$SCRIPT_DIR/create-intermediate-ca.sh"

echo "PKI complète créée."

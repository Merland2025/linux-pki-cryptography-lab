#!/bin/bash

set -euo pipefail

BASE_DIR="${1:-$PWD/pki-clients}"
CLIENT_COUNT="${2:-30}"

if ! [[ "$CLIENT_COUNT" =~ ^[0-9]+$ ]] || [ "$CLIENT_COUNT" -lt 1 ]; then
    echo "ERREUR : le nombre de clients doit être un entier positif." >&2
    exit 1
fi

create_client_directory() {
    local client_dir="$1"

    mkdir -p "$client_dir"/{certs,private,csr,crl}
    chmod 700 "$client_dir/private"
}

echo "Création de $CLIENT_COUNT répertoires PKI..."
echo "Répertoire de base : $BASE_DIR"

mkdir -p "$BASE_DIR"

for i in $(seq 1 "$CLIENT_COUNT"); do
    create_client_directory "$BASE_DIR/client$i"
done

echo
echo "PKI clients créée avec succès."
echo "Clients : $CLIENT_COUNT"
echo "Base   : $BASE_DIR"

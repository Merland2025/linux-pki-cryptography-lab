#!/bin/bash

set -e

./create-root-ca.sh

./create-intermediate-ca.sh

echo "PKI complète créée."

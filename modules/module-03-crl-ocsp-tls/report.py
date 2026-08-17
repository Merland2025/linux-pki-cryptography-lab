#!/usr/bin/env python3

import subprocess
import datetime
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
TESTS_DIR = BASE_DIR / "crypto-validation" / "tests"

tests = [
    "rsa.sh",
    "ecdsa.sh",
    "ed25519.sh",
    "pkcs11.sh",
    "pki.sh",
    "tls.sh",
]

results = []

print("========================================")
print("       MODULE 03 - RAPPORT DE TEST")
print("========================================")
print(f"Date : {datetime.datetime.now()}")
print()

for test in tests:
    test_path = TESTS_DIR / test

    print(f"[TEST] {test}")

    if not test_path.exists():
        print("       FAIL - fichier introuvable")
        results.append((test, 1))
        continue

    result = subprocess.run(
        ["bash", str(test_path)],
        cwd=TESTS_DIR.parent,
        capture_output=True,
        text=True
    )

    print(result.stdout)

    if result.stderr:
        print(result.stderr)

    results.append((test, result.returncode))

print("========================================")
print("       RAPPORT FINAL")
print("========================================")

passed = 0
failed = 0

for name, code in results:
    if code == 0:
        print(f"[OK]   {name}")
        passed += 1
    else:
        print(f"[FAIL] {name}")
        failed += 1

print()
print(f"PASS : {passed}")
print(f"FAIL : {failed}")

if failed == 0:
    print()
    print("Tous les tests sont réussis.")
else:
    print()
    print("Certains tests ont échoué.")

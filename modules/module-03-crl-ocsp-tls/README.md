# Module 03 — Validation cryptographique, PKCS#11, PKI et TLS

## 1. Objectif

Ce module complète les travaux PKI des modules précédents par une série de contrôles cryptographiques et de validations autour d'OpenSSL.

L'objectif est de vérifier concrètement :

* les capacités cryptographiques d'OpenSSL ;
* la disponibilité des providers et algorithmes ;
* la génération et la vérification de signatures RSA ;
* la génération et la vérification de signatures ECDSA ;
* la génération et la vérification de signatures Ed25519 ;
* l'utilisation d'un module PKCS#11 avec SoftHSM ;
* la création et la validation d'une chaîne PKI de test ;
* la vérification d'un certificat serveur dans un contexte TLS ;
* les performances de plusieurs primitives cryptographiques.

Le module constitue principalement un laboratoire de **validation cryptographique**, et non une PKI de production.

---

## 2. Structure

```text
module-03-crl-ocsp-tls/
├── README.md
├── report.py
└── crypto-validation/
    ├── diagnose-openssl.sh
    ├── tests/
    │   ├── benchmark.sh
    │   ├── ecdsa.sh
    │   ├── ed25519.sh
    │   ├── pkcs11.sh
    │   ├── pki.sh
    │   ├── rsa.sh
    │   ├── run_all.sh
    │   └── tls.sh
    └── pki/
```

Les fichiers générés pendant les tests ne constituent pas des artefacts à versionner.

---

## 3. Prérequis

Le laboratoire utilise notamment :

* Bash ;
* OpenSSL ;
* Python 3 ;
* SoftHSM ;
* `pkcs11-tool`.

Vérification d'OpenSSL :

```bash
openssl version -a
```

Vérification des providers :

```bash
openssl list -providers
```

Vérification des algorithmes de signature :

```bash
openssl list -signature-algorithms
```

Vérification des digests :

```bash
openssl list -digest-algorithms
```

---

## 4. Diagnostic OpenSSL

Le script :

```text
crypto-validation/diagnose-openssl.sh
```

permet d'obtenir les informations générales utilisées par le laboratoire :

```bash
cd modules/module-03-crl-ocsp-tls

./crypto-validation/diagnose-openssl.sh
```

Il affiche notamment :

* la version d'OpenSSL ;
* les providers disponibles ;
* les algorithmes de signature ;
* les algorithmes de digest ;
* la valeur de `OPENSSL_CONF`.

Ce diagnostic permet de vérifier l'environnement avant l'exécution des tests.

---

## 5. Test RSA

Le test :

```text
crypto-validation/tests/rsa.sh
```

génère une clé RSA 2048 bits puis réalise une signature SHA-256.

Les étapes sont :

1. génération de la clé privée ;
2. création d'un message de test ;
3. signature avec RSA/SHA-256 ;
4. extraction de la clé publique ;
5. vérification de la signature.

Exécution :

```bash
cd modules/module-03-crl-ocsp-tls/crypto-validation

./tests/rsa.sh
```

Un résultat :

```text
[RSA] OK
```

indique que la signature et sa vérification ont réussi.

---

## 6. Test ECDSA

Le test :

```text
crypto-validation/tests/ecdsa.sh
```

utilise une clé elliptique P-256.

Il réalise :

1. génération de la clé EC ;
2. signature SHA-256 ;
3. extraction de la clé publique ;
4. vérification de la signature.

Exécution :

```bash
cd modules/module-03-crl-ocsp-tls/crypto-validation

./tests/ecdsa.sh
```

Résultat attendu :

```text
[ECDSA] OK
```

---

## 7. Test Ed25519

Le test :

```text
crypto-validation/tests/ed25519.sh
```

vérifie la génération et l'utilisation d'une clé Ed25519.

Il réalise :

1. génération de la clé privée ;
2. extraction de la clé publique ;
3. création d'un message ;
4. signature avec `openssl pkeyutl` ;
5. vérification de la signature.

Exécution :

```bash
cd modules/module-03-crl-ocsp-tls/crypto-validation

./tests/ed25519.sh
```

Résultat attendu :

```text
[Ed25519] OK
```

---

## 8. Test PKCS#11 / SoftHSM

Le test :

```text
crypto-validation/tests/pkcs11.sh
```

vérifie la présence du module SoftHSM :

```text
/usr/lib/softhsm/libsofthsm2.so
```

puis utilise `pkcs11-tool` pour afficher les objets disponibles dans le token.

Exécution :

```bash
cd modules/module-03-crl-ocsp-tls/crypto-validation

./tests/pkcs11.sh
```

Ce test dépend donc de l'installation et de la configuration locale de SoftHSM.

Le PIN actuellement présent dans le script est un **PIN de laboratoire**. Il ne doit pas être réutilisé comme secret réel dans une infrastructure de production.

---

## 9. Test PKI

Le test :

```text
crypto-validation/tests/pki.sh
```

crée une petite PKI indépendante destinée uniquement à la validation.

Il génère :

* une CA racine RSA 2048 bits ;
* une clé serveur ;
* un CSR serveur ;
* un certificat serveur signé par la CA ;
* puis vérifie le certificat avec `openssl verify`.

La PKI de test est créée dans :

```text
crypto-validation/pki/
```

Exécution :

```bash
cd modules/module-03-crl-ocsp-tls/crypto-validation

./tests/pki.sh
```

Le résultat attendu est :

```text
[PKI] OK
```

Cette PKI est indépendante de celle du Module 02.

---

## 10. Test TLS

Le test :

```text
crypto-validation/tests/tls.sh
```

réutilise la PKI de test créée par `pki.sh`.

Il vérifie :

* la chaîne de confiance ;
* le Subject du certificat ;
* l'Issuer ;
* les dates de validité ;
* l'intégrité de la clé privée avec `openssl pkey -check`.

Exécution :

```bash
cd modules/module-03-crl-ocsp-tls/crypto-validation

./tests/pki.sh
./tests/tls.sh
```

Résultat attendu :

```text
[TLS] OK
```

---

## 11. Exécution de l'ensemble des tests

Le script :

```text
crypto-validation/tests/run_all.sh
```

exécute les six tests principaux :

```text
rsa.sh
ecdsa.sh
ed25519.sh
pkcs11.sh
pki.sh
tls.sh
```

Exécution :

```bash
cd modules/module-03-crl-ocsp-tls/crypto-validation

./tests/run_all.sh
```

Le script affiche le nombre de tests réussis et échoués :

```text
PASS : 6
FAIL : 0
```

Le code de retour est nul uniquement lorsque tous les tests réussissent.

---

## 12. Rapport automatisé

Le fichier :

```text
report.py
```

permet d'exécuter les mêmes six tests et de produire un rapport synthétique.

Exécution :

```bash
cd modules/module-03-crl-ocsp-tls

python3 report.py
```

Le rapport indique pour chaque test :

* son existence ;
* sa sortie ;
* son code de retour ;
* son statut `OK` ou `FAIL`.

Un résultat sans échec se termine par :

```text
PASS : 6
FAIL : 0

Tous les tests sont réussis.
```

---

## 13. Benchmark cryptographique

Le script :

```text
crypto-validation/tests/benchmark.sh
```

est séparé de `run_all.sh` car les benchmarks peuvent être plus longs et leurs résultats dépendent fortement de la machine utilisée.

Il mesure notamment :

* RSA 2048 ;
* AES-256-GCM ;
* SHA-256.

Exécution :

```bash
cd modules/module-03-crl-ocsp-tls/crypto-validation

./tests/benchmark.sh
```

Les résultats doivent être interprétés comme des mesures relatives à la machine et à l'environnement OpenSSL utilisés.

---

## 14. Artefacts générés

Les tests créent temporairement différents fichiers :

```text
*.key
*.sig
message.txt
```

ainsi qu'une PKI de test sous :

```text
crypto-validation/pki/
```

Ces artefacts sont exclus du dépôt Git par `.gitignore`.

Les clés privées et autres secrets de laboratoire ne doivent pas être versionnés.

Vérification :

```bash
git status --short
```

Le dépôt doit rester propre après les tests, à l'exception des fichiers explicitement destinés à être suivis.

---

## 15. Séquence recommandée

Pour effectuer une validation complète :

```bash
cd modules/module-03-crl-ocsp-tls

./crypto-validation/diagnose-openssl.sh

cd crypto-validation

./tests/run_all.sh

cd ..

python3 report.py

cd crypto-validation

./tests/benchmark.sh
```

---

## 16. Interprétation

Un résultat positif du module signifie que l'environnement est capable de réaliser les opérations testées :

* RSA ;
* ECDSA ;
* Ed25519 ;
* PKCS#11 ;
* validation de certificat ;
* opérations élémentaires liées à TLS.

Cela ne constitue pas à lui seul une validation complète d'une infrastructure PKI de production.

Les tests sont volontairement ciblés sur les primitives cryptographiques, la validation de certificats et l'intégration avec certains composants logiciels.

---

## 17. Limites

Ce module ne doit pas être considéré comme une implémentation complète de :

* gestion de CRL en production ;
* service OCSP complet ;
* HSM de production ;
* gestion industrielle des clés ;
* politique de certification complète ;
* infrastructure TLS de production.

Ces sujets peuvent être développés dans des étapes ultérieures du laboratoire.

---

## 18. Relation avec les modules précédents

Le Module 01 couvre principalement les fondamentaux Linux et Bash nécessaires à l'automatisation.

Le Module 02 construit une PKI OpenSSL structurée avec :

```text
Root CA
   ↓
Intermediate CA
   ↓
Certificats
```

Le Module 03 ajoute une couche de validation cryptographique et d'expérimentation autour d'OpenSSL, PKCS#11 et TLS.

L'ensemble constitue progressivement un laboratoire de PKI et de cryptographie automatisée.

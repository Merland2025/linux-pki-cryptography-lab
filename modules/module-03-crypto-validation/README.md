# Module 03 — Validation cryptographique, PKCS#11 et PKI de test

## 1. Objectif

Le Module 03 est consacré à la validation des primitives cryptographiques et à l'expérimentation d'OpenSSL, de PKCS#11 et de SoftHSM.

Il complète le Module 02, qui construit la PKI OpenSSL, en ajoutant une série de tests automatisés permettant de vérifier le fonctionnement de l'environnement cryptographique.

Le module couvre notamment :

* RSA ;
* ECDSA ;
* Ed25519 ;
* PKCS#11 / SoftHSM ;
* génération et validation d'une PKI de test ;
* validation de certificats ;
* diagnostic de l'environnement OpenSSL ;
* benchmarks cryptographiques.

Le Module 03 constitue un laboratoire de validation et d'expérimentation. Il ne constitue pas une infrastructure PKI de production.

---

## 2. Structure

```text
module-03-crypto-validation/
├── README.md
└── crypto-validation/
    ├── diagnose-openssl.sh
    └── tests/
        ├── benchmark.sh
        ├── ecdsa.sh
        ├── ed25519.sh
        ├── pkcs11.sh
        ├── pki.sh
        ├── rsa.sh
        ├── run_all.sh
        └── tls.sh
```

Les scripts sont regroupés dans `crypto-validation/`.

Les fichiers générés temporairement pendant les tests ne doivent pas être considérés comme des artefacts permanents du laboratoire.

---

## 3. Prérequis

Le module utilise notamment :

* Bash ;
* OpenSSL ;
* Python 3 lorsque nécessaire ;
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

Vérification des digest :

```bash
openssl list -digest-algorithms
```

---

## 4. Diagnostic OpenSSL

Le script :

```text
crypto-validation/diagnose-openssl.sh
```

permet de contrôler l'environnement OpenSSL avant les tests.

Exécution :

```bash
cd ~/pki-automation/modules/module-03-crypto-validation

bash crypto-validation/diagnose-openssl.sh
```

Le diagnostic permet notamment d'observer :

* la version d'OpenSSL ;
* les providers disponibles ;
* les algorithmes de signature ;
* les algorithmes de digest ;
* la configuration OpenSSL utilisée.

---

## 5. Test RSA

Le test :

```text
crypto-validation/tests/rsa.sh
```

valide une opération de signature RSA.

Le scénario comprend :

1. génération d'une clé RSA ;
2. préparation d'un message de test ;
3. signature du message ;
4. extraction ou utilisation de la clé publique ;
5. vérification de la signature.

Exécution :

```bash
cd ~/pki-automation/modules/module-03-crypto-validation

bash crypto-validation/tests/rsa.sh
```

Le résultat attendu est une validation réussie du test RSA.

---

## 6. Test ECDSA

Le test :

```text
crypto-validation/tests/ecdsa.sh
```

valide l'utilisation d'une clé elliptique et d'une signature ECDSA.

Le scénario vérifie notamment :

1. la génération de la clé ;
2. la signature ;
3. la récupération de la clé publique ;
4. la vérification de la signature.

Exécution :

```bash
cd ~/pki-automation/modules/module-03-crypto-validation

bash crypto-validation/tests/ecdsa.sh
```

---

## 7. Test Ed25519

Le test :

```text
crypto-validation/tests/ed25519.sh
```

valide la génération et l'utilisation d'une clé Ed25519 ainsi que les opérations de signature et de vérification.

Exécution :

```bash
cd ~/pki-automation/modules/module-03-crypto-validation

bash crypto-validation/tests/ed25519.sh
```

---

## 8. Test PKCS#11 / SoftHSM

Le test :

```text
crypto-validation/tests/pkcs11.sh
```

permet de vérifier l'intégration avec PKCS#11 et SoftHSM.

Il dépend de l'environnement local et notamment de la présence du module PKCS#11 SoftHSM.

Une installation typique utilise :

```text
/usr/lib/softhsm/libsofthsm2.so
```

Exécution :

```bash
cd ~/pki-automation/modules/module-03-crypto-validation

bash crypto-validation/tests/pkcs11.sh
```

Le PIN utilisé dans le laboratoire doit être considéré comme un secret de démonstration uniquement.

Il ne doit pas être réutilisé dans une infrastructure réelle.

---

## 9. Test PKI

Le test :

```text
crypto-validation/tests/pki.sh
```

met en place une petite PKI indépendante destinée aux validations du module.

Elle permet notamment de tester :

* une autorité de certification de laboratoire ;
* une clé serveur ;
* un CSR ;
* un certificat serveur ;
* la vérification du certificat.

Cette PKI de test est indépendante de la PKI construite dans le Module 02.

Exécution :

```bash
cd ~/pki-automation/modules/module-03-crypto-validation

bash crypto-validation/tests/pki.sh
```

---

## 10. Validation TLS de laboratoire

Le script :

```text
crypto-validation/tests/tls.sh
```

effectue des contrôles sur le certificat et la clé privée utilisés par la PKI de test du Module 03.

Il vérifie notamment :

* la validation du certificat ;
* le Subject ;
* l'Issuer ;
* les dates de validité ;
* la validité de la clé privée ;
* la correspondance entre certificat et clé lorsque le scénario le prévoit.

Exécution :

```bash
cd ~/pki-automation/modules/module-03-crypto-validation

bash crypto-validation/tests/pki.sh
bash crypto-validation/tests/tls.sh
```

Cette validation TLS reste une validation cryptographique de laboratoire.

La mise en œuvre CRL/OCSP/TLS plus complète appartient au Module 04.

---

## 11. Exécution de tous les tests

Le script :

```text
crypto-validation/tests/run_all.sh
```

centralise les tests du Module 03.

Les tests comprennent :

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
cd ~/pki-automation/modules/module-03-crypto-validation

bash crypto-validation/tests/run_all.sh
```

Le script retourne un code nul lorsque tous les tests réussissent.

Un résultat de type :

```text
PASS : 6
FAIL : 0
```

indique que les six tests du module ont réussi.

---

## 12. Benchmark

Le script :

```text
crypto-validation/tests/benchmark.sh
```

permet de réaliser des mesures de performance cryptographique.

Les résultats dépendent notamment :

* du processeur ;
* de la mémoire ;
* de la version d'OpenSSL ;
* des providers disponibles ;
* de la configuration du système.

Exécution :

```bash
cd ~/pki-automation/modules/module-03-crypto-validation

bash crypto-validation/tests/benchmark.sh
```

Les résultats doivent être interprétés comme des mesures de laboratoire et non comme des valeurs universelles.

---

## 13. Artefacts de test

Certains tests peuvent générer temporairement des fichiers tels que :

```text
*.key
*.sig
message.txt
```

ainsi que des fichiers associés à la PKI de test.

Ces fichiers ne doivent pas être versionnés lorsqu'ils sont générés automatiquement par les tests et qu'ils ne constituent pas des ressources nécessaires au laboratoire.

Vérification :

```bash
cd ~/pki-automation

git status --short
```

---

## 14. Séquence recommandée

Une validation complète du Module 03 peut être réalisée avec :

```bash
cd ~/pki-automation/modules/module-03-crypto-validation

bash crypto-validation/diagnose-openssl.sh

bash crypto-validation/tests/run_all.sh

bash crypto-validation/tests/benchmark.sh
```

---

## 15. Résultat attendu

Le résultat recherché est :

```text
PASS : 6
FAIL : 0
```

ou le nombre de tests effectivement présents dans `run_all.sh`.

Le code retour doit être :

```text
0
```

lorsque tous les tests réussissent.

---

## 16. Limites

Le Module 03 ne constitue pas :

* une PKI de production ;
* une infrastructure HSM de production ;
* une politique de certification complète ;
* une gestion industrielle des clés ;
* un service OCSP de production ;
* une infrastructure CRL de production.

Les fonctionnalités CRL, OCSP et TLS associées sont traitées dans le Module 04.

---

## 17. Relation avec les modules précédents

Le Module 01 fournit les bases Linux et Bash nécessaires à l'automatisation.

Le Module 02 construit une PKI OpenSSL structurée :

```text
Root CA
   ↓
Intermediate CA
   ↓
Certificats
```

Le Module 03 ajoute les validations cryptographiques et les expérimentations autour d'OpenSSL, PKCS#11, SoftHSM et des primitives de signature.

Le Module 04 poursuit le laboratoire avec la révocation, les CRL, OCSP et les validations TLS associées.

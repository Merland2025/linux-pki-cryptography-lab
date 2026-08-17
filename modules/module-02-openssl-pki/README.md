# Module 02 — OpenSSL & PKI

## Objectif

Ce module met en place une infrastructure PKI de laboratoire sous Linux avec OpenSSL.

L'objectif est de comprendre et automatiser les principales étapes du cycle de vie des certificats X.509 :

* génération des clés ;
* création d'une Root CA ;
* création d'une Intermediate CA ;
* génération de CSR ;
* émission de certificats serveur et client ;
* gestion des Subject Alternative Names (SAN) ;
* construction d'une chaîne de confiance ;
* validation des certificats ;
* automatisation avec Bash.

---

## Architecture

```text
                    Root CA
                       │
                       │ signe
                       ▼
                Intermediate CA
                  │           │
                  │           │
               signe        signe
                  │           │
                  ▼           ▼
          Server Certificate  Client Certificate
          web.example.com
```

La Root CA constitue l'autorité de certification racine.

L'Intermediate CA est utilisée pour émettre les certificats d'entités finales.

---

## Arborescence

```text
module-02-openssl-pki/
├── certs/
│   ├── ca-chain.crt
│   ├── client.crt
│   ├── intermediate-ca.crt
│   ├── root-ca.crt
│   └── web.example.com.crt
│
├── scripts/
│   ├── config.sh
│   ├── create-root-ca.sh
│   ├── create-intermediate-ca.sh
│   ├── create-server-cert.sh
│   └── validate-cert.sh
│
└── README.md
```

Les clés privées ne sont volontairement pas présentes dans le dépôt Git.

---

## 1. Root CA

La Root CA est générée avec une clé RSA de 4096 bits.

Paramètres principaux :

```text
RSA : 4096 bits
Validité : 3650 jours
Algorithme de signature : SHA-256
```

La clé privée est protégée localement avec :

```bash
chmod 600 root-ca.key
```

La Root CA signe ensuite le certificat de l'Intermediate CA.

---

## 2. Intermediate CA

Une Intermediate CA est créée afin d'éviter d'utiliser directement la Root CA pour émettre les certificats finaux.

Architecture :

```text
Root CA
   │
   └── Intermediate CA
           │
           ├── Server certificate
           └── Client certificate
```

La clé de l'Intermediate CA est également générée en RSA 4096 bits.

Un CSR est ensuite créé puis signé par la Root CA.

---

## 3. Certificat serveur

Le certificat :

```text
web.example.com
```

est généré à partir d'une clé RSA 2048 bits et d'un CSR.

Le certificat contient notamment le Subject Alternative Name :

```text
DNS:web.example.com
```

La signature est réalisée par l'Intermediate CA.

---

## 4. Certificat client

Un certificat client a également été généré afin de préparer les futurs tests d'authentification TLS mutuelle.

Le certificat client est signé par l'Intermediate CA.

---

## 5. Chaîne de confiance

La chaîne utilisée pour la validation est :

```text
Root CA
   │
   ▼
Intermediate CA
   │
   ▼
web.example.com
```

Le fichier :

```text
ca-chain.crt
```

permet de fournir la chaîne de confiance nécessaire à la validation.

---

## 6. Validation

La validation est réalisée avec :

```bash
openssl verify \
  -CAfile intermediate-ca/certs/ca-chain.crt \
  certs/web.example.com.crt
```

Résultat obtenu :

```text
certs/web.example.com.crt: OK
```

Une validation avec CRL a également été réalisée lors du travail pratique et a retourné :

```text
certs/web.example.com.crt: OK
```

---

## 7. Inspection des certificats

Les informations importantes des certificats peuvent être inspectées avec :

```bash
openssl x509 -in certs/web.example.com.crt -noout -subject
```

```bash
openssl x509 -in certs/web.example.com.crt -noout -issuer
```

```bash
openssl x509 -in certs/web.example.com.crt -noout -dates
```

```bash
openssl x509 -in certs/web.example.com.crt -noout -fingerprint -sha256
```

Le script `validate-cert.sh` regroupe ces opérations afin de faciliter les contrôles.

---

## 8. Analyse ASN.1 / DER

Le certificat serveur a également été converti au format DER afin d'analyser sa structure ASN.1 :

```bash
openssl x509 \
  -in certs/web.example.com.crt \
  -outform DER \
  -out web.der
```

Puis :

```bash
openssl asn1parse \
  -in web.der \
  -inform DER
```

Cette analyse permet notamment d'identifier :

* le numéro de série ;
* l'algorithme de signature ;
* le Subject ;
* l'Issuer ;
* les dates de validité ;
* la clé publique ;
* les extensions X.509 ;
* le Subject Alternative Name ;
* le Subject Key Identifier ;
* l'Authority Key Identifier.

---

## 9. Automatisation

La création de la PKI est partiellement automatisée avec des scripts Bash.

Scripts principaux :

```text
create-root-ca.sh
create-intermediate-ca.sh
create-server-cert.sh
validate-cert.sh
```

Le script `create-pki.sh` permet d'enchaîner les opérations de création des autorités de certification.

Les scripts utilisent :

```bash
set -e
```

afin d'arrêter l'exécution lorsqu'une commande échoue.

---

## 10. Sécurité

Les clés privées ne sont pas versionnées dans Git.

Le `.gitignore` du projet exclut notamment :

```text
private/
*.key
*.pem
*.p12
*.pfx
*.jks
```

Les fichiers d'état sensibles de la PKI sont également exclus.

Avant chaque publication, il faut vérifier qu'aucune clé privée n'est présente dans les fichiers suivis par Git.

Exemple :

```bash
git ls-files | grep -E '\.(key|p12|pfx|jks)$'
```

Un résultat vide est attendu.

---

## 11. Limites actuelles

Cette PKI est un environnement de laboratoire et non une PKI de production.

Les prochaines améliorations porteront notamment sur :

* extensions `basicConstraints` ;
* `keyUsage` ;
* `extendedKeyUsage` ;
* configuration complète d'OpenSSL CA ;
* révocation des certificats ;
* CRL ;
* OCSP ;
* authentification TLS mutuelle ;
* stockage sécurisé des clés privées ;
* PKCS#11 ;
* SoftHSM ;
* HSM matériel ;
* YubiKey.

Ces évolutions feront partie des modules suivants du projet.

---

## Compétences travaillées

```text
Linux
Bash
OpenSSL
PKI
X.509
RSA
CSR
Root CA
Intermediate CA
Certificate Chain
SAN
ASN.1
DER
Certificate Validation
Git
Security Best Practices
```

---

## Statut

**Module 02 — Réalisé / laboratoire fonctionnel**

Les fonctionnalités suivantes ont été testées :

* [x] Root CA
* [x] Intermediate CA
* [x] Certificat serveur
* [x] Certificat client
* [x] Certificate chain
* [x] SAN
* [x] Validation OpenSSL
* [x] Inspection X.509
* [x] Analyse ASN.1/DER
* [x] Automatisation Bash
* [x] Exclusion des clés privées du dépôt Git

Les fonctionnalités de révocation, OCSP, TLS avancé, PKCS#11, SoftHSM et YubiKey seront approfondies dans les modules suivants.

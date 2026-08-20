# Module 04 — CRL, OCSP et TLS

## 1. Objectif

Le Module 04 poursuit la construction du laboratoire PKI en ajoutant les mécanismes liés à la révocation des certificats et à la vérification dynamique de leur statut.

Le module couvre :

* la révocation d'un certificat ;
* la génération d'une CRL ;
* la vérification d'une CRL ;
* la mise en place d'un responder OCSP de laboratoire ;
* l'interrogation du responder OCSP ;
* la vérification de la signature de la réponse OCSP ;
* la vérification du numéro de série ;
* la vérification du statut `revoked` ;
* la validation d'un certificat dans un contexte TLS ;
* l'automatisation de l'ensemble des contrôles.

Le module reste un laboratoire de démonstration et de validation.

---

## 2. Structure

```text
module-04-crl-ocsp-tls/
├── README.md
├── setup.sh
├── crl/
├── ocsp/
├── tests/
│   ├── crl.sh
│   ├── ocsp.sh
│   ├── run_all.sh
│   └── tls.sh
└── tls/
    └── README.md
```

Le répertoire `crl/` contient les éléments liés aux listes de révocation.

Le répertoire `ocsp/` contient les éléments liés au responder OCSP.

Le répertoire `tests/` contient les tests automatisés.

Le répertoire `tls/` contient la documentation spécialisée concernant TLS.

---

## 3. Relation avec le Module 02

Le Module 02 construit la hiérarchie PKI :

```text
Root CA
   ↓
Intermediate CA
   ↓
Certificat serveur
```

Le Module 04 ajoute une dimension essentielle à cette PKI :

```text
Certificat
     ↓
Révocation
     ↓
CRL / OCSP
     ↓
Validation du statut
```

Le module permet ainsi d'expérimenter le cycle de vie d'un certificat après son émission.

---

## 4. Préparation

Le script :

```text
setup.sh
```

prépare l'environnement nécessaire aux tests du module.

Exécution :

```bash
cd ~/pki-automation/modules/module-04-crl-ocsp-tls

bash setup.sh
```

Le script doit être exécuté avant les tests lorsque l'environnement du laboratoire doit être initialisé ou régénéré.

---

## 5. CRL

Le test :

```text
tests/crl.sh
```

valide le fonctionnement de la liste de révocation.

Le scénario général est :

1. identifier le certificat de test ;
2. révoquer le certificat ;
3. générer ou mettre à jour la CRL ;
4. vérifier la présence du certificat révoqué ;
5. contrôler les informations de révocation.

Une CRL permet à une autorité de certification de publier une liste de certificats qui ne doivent plus être considérés comme valides.

Exécution :

```bash
cd ~/pki-automation/modules/module-04-crl-ocsp-tls

bash tests/crl.sh
```

---

## 6. OCSP

Le test :

```text
tests/ocsp.sh
```

valide l'interrogation du responder OCSP.

Le scénario vérifie notamment :

* l'envoi de la requête OCSP ;
* la réception de la réponse ;
* la vérification cryptographique de la réponse ;
* l'identification du certificat concerné ;
* le numéro de série ;
* le statut du certificat.

Dans le scénario de laboratoire, le certificat testé doit être déclaré :

```text
Cert Status: revoked
```

Une réponse correctement vérifiée doit notamment permettre d'obtenir :

```text
Response verify OK
```

Exécution :

```bash
cd ~/pki-automation/modules/module-04-crl-ocsp-tls

bash tests/ocsp.sh
```

---

## 7. Responder OCSP

Le répertoire :

```text
ocsp/
```

regroupe les éléments nécessaires au scénario OCSP du laboratoire.

Le responder utilisé dans ce module est destiné à l'expérimentation locale.

Il ne doit pas être considéré comme un service OCSP destiné à une infrastructure de production.

---

## 8. Vérification du certificat révoqué

Le scénario permet de vérifier la cohérence entre :

```text
Certificat
    ↓
Numéro de série
    ↓
Révocation
    ↓
CRL
    ↓
Réponse OCSP
```

Le résultat attendu est la cohérence entre les différents mécanismes de révocation.

---

## 9. TLS

Le test :

```text
tests/tls.sh
```

effectue les contrôles TLS prévus par le laboratoire.

Il vérifie notamment les éléments nécessaires à la validation du certificat et de la clé privée.

Exécution :

```bash
cd ~/pki-automation/modules/module-04-crl-ocsp-tls

bash tests/tls.sh
```

La documentation détaillée de cette partie se trouve dans :

```text
tls/README.md
```

---

## 10. Exécution de tous les tests

Le script :

```text
tests/run_all.sh
```

regroupe les tests du Module 04 :

```text
crl.sh
ocsp.sh
tls.sh
```

Exécution :

```bash
cd ~/pki-automation/modules/module-04-crl-ocsp-tls

bash tests/run_all.sh
```

Le script retourne :

```text
CODE=0
```

lorsque tous les tests réussissent.

Le résultat final doit indiquer que tous les tests sont passés.

---

## 11. Séquence recommandée

Pour exécuter le laboratoire :

```bash
cd ~/pki-automation/modules/module-04-crl-ocsp-tls

bash setup.sh

bash tests/run_all.sh
```

En cas de diagnostic individuel :

```bash
bash tests/crl.sh
bash tests/ocsp.sh
bash tests/tls.sh
```

---

## 12. Interprétation

Une validation réussie indique que le scénario de laboratoire permet de :

* révoquer un certificat ;
* produire et vérifier une CRL ;
* interroger un responder OCSP ;
* vérifier cryptographiquement une réponse OCSP ;
* confirmer le statut du certificat ;
* réaliser les contrôles TLS prévus.

Cela ne constitue pas une validation d'une infrastructure PKI de production.

---

## 13. Limites

Le module ne fournit pas une infrastructure de production.

Il ne couvre notamment pas de manière industrielle :

* la haute disponibilité d'un responder OCSP ;
* la distribution mondiale de CRL ;
* les politiques de rétention ;
* les HSM de production ;
* la gestion industrielle des clés ;
* la supervision de production ;
* les procédures opérationnelles complètes d'une autorité de certification.

Ces sujets peuvent être ajoutés dans des modules ultérieurs.

---

## 14. Sécurité

Les certificats, clés et secrets utilisés dans ce module appartiennent à un environnement de laboratoire.

Ils ne doivent pas être réutilisés dans une infrastructure réelle.

Les secrets de démonstration doivent rester limités au laboratoire.

---

## 15. Relation avec les modules précédents

```text
Module 01
Linux / Bash
     ↓
Module 02
PKI OpenSSL
     ↓
Module 03
Validation cryptographique
     ↓
Module 04
CRL / OCSP / TLS
```

Le Module 04 constitue donc une extension fonctionnelle de la PKI construite dans les modules précédents.

# Module 04- Validation TLS

## 1. Objectif

Cette partie du Module 04 est consacrée aux contrôles TLS associés au laboratoire CRL/OCSP.

L'objectif est de vérifier que les éléments cryptographiques nécessaires à une utilisation TLS sont cohérents :

* certificat serveur ;
* autorité de certification ;
* clé privée ;
* chaîne de certification ;
* dates de validité ;
* correspondance entre certificat et clé.

Cette partie reste un environnement de laboratoire.

---

## 2. Structure

```text
module-04-crl-ocsp-tls/
└── tls/
    └── README.md
```

Les scripts de validation TLS sont situés dans :

```text
module-04-crl-ocsp-tls/tests/tls.sh
```

---

## 3. Certificat serveur

Le certificat serveur doit pouvoir être validé par l'autorité de certification prévue par le laboratoire.

Une vérification typique utilise :

```bash
openssl verify \
    -CAfile <CA_CERTIFICATE> \
    <SERVER_CERTIFICATE>
```

Le résultat attendu est :

```text
<certificate>: OK
```

---

## 4. Informations du certificat

Les informations principales peuvent être affichées avec :

```bash
openssl x509 \
    -in <SERVER_CERTIFICATE> \
    -noout \
    -subject \
    -issuer \
    -dates
```

Ces informations permettent notamment de contrôler :

* le Subject ;
* l'Issuer ;
* la date de début de validité ;
* la date d'expiration.

---

## 5. Clé privée

La clé privée doit être lisible par OpenSSL et être structurellement valide.

Une vérification peut être réalisée avec :

```bash
openssl pkey \
    -in <SERVER_KEY> \
    -check \
    -noout
```

Un résultat :

```text
Key is valid
```

indique que la clé privée est valide.

---

## 6. Correspondance certificat / clé

Le laboratoire doit également vérifier que le certificat serveur correspond à la clé privée utilisée.

Cette vérification permet d'éviter une configuration TLS dans laquelle :

```text
Certificat A
     +
Clé privée B
```

seraient utilisés ensemble.

Le test automatisé du module réalise cette vérification selon le scénario défini dans :

```text
tests/tls.sh
```

---

## 7. Validation automatisée

Le test TLS peut être exécuté directement :

```bash
cd ~/pki-automation/modules/module-04-crl-ocsp-tls

bash tests/tls.sh
```

Il peut également être exécuté avec l'ensemble du Module 04 :

```bash
bash tests/run_all.sh
```

---

## 8. Relation avec CRL et OCSP

TLS ne doit pas être considéré séparément du cycle de vie du certificat.

Le laboratoire met en relation :

```text
              CA
              │
              ▼
        Certificat TLS
              │
       ┌──────┴──────┐
       ▼             ▼
      CRL           OCSP
       │             │
       └──────┬──────┘
              ▼
       Statut du certificat
              │
              ▼
          Validation
```

Le Module 04 permet ainsi d'expérimenter les mécanismes qui interviennent après l'émission du certificat.

---

## 9. Limites

Les contrôles réalisés dans ce laboratoire ne constituent pas une configuration TLS de production.

Ils ne couvrent pas nécessairement :

* la configuration complète d'un serveur web ;
* la gestion de plusieurs versions TLS ;
* la configuration industrielle des suites cryptographiques ;
* la haute disponibilité ;
* la gestion de certificats en production ;
* la supervision ;
* la rotation industrielle des certificats ;
* les procédures opérationnelles d'une infrastructure TLS réelle.

---

## 10. Séquence de validation

Pour effectuer une validation complète du Module 04 :

```bash
cd ~/pki-automation/modules/module-04-crl-ocsp-tls

bash setup.sh
bash tests/run_all.sh
```

Pour effectuer uniquement le contrôle TLS :

```bash
bash tests/tls.sh
```

Un résultat :

```text
[TLS] OK
```

indique que les contrôles TLS prévus par le laboratoire ont réussi.


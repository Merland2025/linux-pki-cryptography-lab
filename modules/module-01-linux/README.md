# Module 01 — Linux, Bash & PKI Automation

## Objectif

Ce module constitue la base du laboratoire d'automatisation PKI.

L'objectif est de maîtriser les commandes Linux et Bash nécessaires à la
préparation d'une infrastructure PKI reproductible et maintenable.

Les compétences travaillées sont notamment :

* navigation et manipulation de l'arborescence Linux ;
* création et suppression de répertoires ;
* gestion des permissions Unix ;
* automatisation avec Bash ;
* utilisation de `set -euo pipefail` ;
* utilisation de paramètres dans un script ;
* validation des arguments ;
* création d'une arborescence PKI reproductible ;
* protection des répertoires contenant des données sensibles ;
* utilisation de Git pour versionner uniquement les fichiers utiles.

---

## Architecture du module

Le module est organisé de manière indépendante afin que les scripts puissent
être exécutés depuis n'importe quel répertoire.

```text
module-01-linux/
├── exercises/
├── scripts/
│   └── create-pki-clients.sh
└── README.md
```

Le répertoire `pki-clients/` est généré automatiquement par le script mais
n'est pas versionné dans Git.

---

## Exercice : création d'une arborescence PKI

L'exercice consiste à automatiser la création d'une arborescence destinée à
plusieurs clients PKI.

Chaque client possède les sous-répertoires suivants :

```text
client1/
├── certs/
├── private/
├── csr/
└── crl/
```

Le même modèle est ensuite reproduit pour les autres clients :

```text
client2/
├── certs/
├── private/
├── csr/
└── crl/

client3/
├── certs/
├── private/
├── csr/
└── crl/

...

client30/
├── certs/
├── private/
├── csr/
└── crl/
```

### Signification des répertoires

| Répertoire | Rôle                                        |
| ---------- | ------------------------------------------- |
| `certs/`   | certificats du client                       |
| `private/` | clés privées et données sensibles           |
| `csr/`     | demandes de signature de certificat         |
| `crl/`     | informations liées aux listes de révocation |

Le répertoire `private/` doit être protégé avec des permissions restrictives.

---

## Script principal

Le script d'automatisation est :

```text
scripts/create-pki-clients.sh
```

Il permet de créer plusieurs clients PKI sans avoir à créer manuellement
chaque répertoire.

Le script utilise une valeur par défaut de :

```text
30 clients
```

et crée l'arborescence dans :

```text
pki-clients/
```

à l'intérieur du module.

---

## Utilisation

Depuis le répertoire du module :

```bash
cd ~/pki-automation/modules/module-01-linux
```

Lancer le script avec les valeurs par défaut :

```bash
./scripts/create-pki-clients.sh
```

Résultat attendu :

```text
Création de 30 répertoires PKI...
Répertoire de base : /home/merland/pki-automation/modules/module-01-linux/pki-clients

PKI clients créée avec succès.
Clients : 30
Base   : /home/merland/pki-automation/modules/module-01-linux/pki-clients
```

---

## Utilisation avec des paramètres

Le script accepte également :

```text
create-pki-clients.sh [BASE_DIR] [NB_CLIENTS]
```

Par exemple :

```bash
./scripts/create-pki-clients.sh /tmp/pki-module01-test 5
```

Cette commande crée :

```text
/tmp/pki-module01-test/
├── client1/
├── client2/
├── client3/
├── client4/
└── client5/
```

Chaque client contient :

```text
certs/
private/
csr/
crl/
```

---

## Vérification de l'arborescence

Après exécution :

```bash
find /tmp/pki-module01-test -maxdepth 2 -type d | sort
```

Exemple de résultat :

```text
/tmp/pki-module01-test
/tmp/pki-module01-test/client1
/tmp/pki-module01-test/client1/certs
/tmp/pki-module01-test/client1/crl
/tmp/pki-module01-test/client1/csr
/tmp/pki-module01-test/client1/private
/tmp/pki-module01-test/client2
/tmp/pki-module01-test/client2/certs
/tmp/pki-module01-test/client2/crl
/tmp/pki-module01-test/client2/csr
/tmp/pki-module01-test/client2/private
```

---

## Protection des clés privées

Le répertoire `private/` doit être accessible uniquement par son propriétaire.

La permission attendue est :

```text
drwx------
```

Elle peut être vérifiée avec :

```bash
stat -c '%A %n' /tmp/pki-module01-test/client1/private
```

Résultat attendu :

```text
drwx------ /tmp/pki-module01-test/client1/private
```

Cette protection est importante car les futures clés privées PKI seront
stockées dans ces répertoires.

---

## Sécurité

Le module ne versionne aucune clé privée.

Les fichiers suivants doivent rester exclus du dépôt Git :

```text
*.key
*.pem
*.p12
*.pfx
*.jks
private/
pki-clients/
```

Le répertoire généré par le script :

```text
pki-clients/
```

est également exclu du dépôt car il s'agit d'un artefact de laboratoire
généré automatiquement.

---

## Tests réalisés

### Test avec 5 clients

```bash
./scripts/create-pki-clients.sh /tmp/pki-module01-test 5
```

Résultat :

```text
Création de 5 répertoires PKI...
Répertoire de base : /tmp/pki-module01-test

PKI clients créée avec succès.
Clients : 5
Base   : /tmp/pki-module01-test
```

### Vérification des permissions

```bash
stat -c '%A %n' /tmp/pki-module01-test/client1/private
```

Résultat :

```text
drwx------ /tmp/pki-module01-test/client1/private
```

### Test avec la configuration par défaut

```bash
./scripts/create-pki-clients.sh
```

Résultat :

```text
Clients : 30
```

Les répertoires générés ont ensuite été supprimés afin de ne pas les
versionner dans Git.

---

## Nettoyage

Pour supprimer un environnement de test :

```bash
rm -rf /tmp/pki-module01-test
```

Pour supprimer l'arborescence générée par défaut :

```bash
rm -rf pki-clients
```

Attention : `rm -rf` supprime définitivement les fichiers sans demander de
confirmation.

---

## Git

Avant de valider le module, vérifier l'état du dépôt :

```bash
cd ~/pki-automation
git status --short
```

Vérifier l'absence de secrets :

```bash
git diff --cached --name-only | \
grep -E '\.(key|p12|pfx|jks|pem)$' \
&& echo "ERREUR : secret détecté !" \
|| echo "OK : aucun secret à committer"
```

Vérifier les problèmes de formatage Git :

```bash
git diff --cached --check
```

Les fichiers attendus pour ce module sont principalement :

```text
.gitignore
modules/module-01-linux/README.md
modules/module-01-linux/scripts/create-pki-clients.sh
```

---

## Compétences acquises

À la fin de ce module, les compétences suivantes sont acquises :

* création automatisée d'une arborescence PKI ;
* écriture de scripts Bash robustes ;
* utilisation de paramètres de script ;
* gestion des valeurs par défaut ;
* contrôle des permissions Unix ;
* séparation des données générées et du code source ;
* protection des informations sensibles ;
* vérification automatisée des résultats ;
* préparation d'un projet PKI propre pour Git.

---

## Suite du laboratoire

Ce module constitue la fondation Linux et Bash du projet.

Le module suivant utilise ces bases pour travailler directement avec
OpenSSL et construire une infrastructure PKI comprenant notamment :

* une Root CA ;
* une Intermediate CA ;
* des certificats serveur ;
* une chaîne de confiance ;
* des extensions X.509 ;
* la validation des certificats ;
* l'automatisation complète avec Bash.

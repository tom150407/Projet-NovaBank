# NovaBank Core - Projet PostgreSQL

## Description
Ce projet contient l'architecture de la base de données pour la banque en ligne NovaBank.
Il inclut la création de tables sécurisées, la gestion des privilèges, l'optimisation avec des index, et l'automatisation via des triggers et procédures (virements atomiques).

## Contenu du dépôt
- `scripts/` : Scripts Bash d'installation et de déploiement.
- `sql/` : Scripts SQL classés par ordre d'exécution (Tables, Données, Droits, Vues, Index, Triggers, Procédures, Tests).
- `backups/` : Sauvegarde complète de la base au format .dump.

## Comment déployer le projet
1. Clonez ce dépôt.
2. Allez dans le dossier `scripts/`.
3. Exécutez le script d'installation du serveur : `./00_install_server.sh`
4. Exécutez le script de déploiement complet : `./run_all.sh`

*Note : L'IA a été utilisée comme assistant pédagogique (explication des erreurs Linux, structure du projet).*

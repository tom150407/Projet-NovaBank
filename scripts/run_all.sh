#!/bin/bash
# Script de reconstruction complète de la base NovaBank

echo "⚠️ ATTENTION : Cela va supprimer et recréer toute la base NovaBank."
read -p "Es-tu sûr de vouloir continuer ? (o/n) : " confirm

if [[ $confirm != [oO] ]]; then
    echo "Annulation."
    exit 1
fi

echo "--- 1. Recréation de la base de données ---"
sudo -u postgres dropdb --if-exists novabank
sudo -u postgres createdb novabank

echo "--- 2. Création des tables ---"
cat ../sql/01_tables.sql | sudo -u postgres psql -d novabank -q

echo "--- 3. Injection des données (1 000 000 lignes, patientez...) ---"
cat ../sql/02_seed_data.sql | sudo -u postgres psql -d novabank -q

echo "--- 4. Configuration des droits ---"
cat ../sql/03_privileges.sql | sudo -u postgres psql -d novabank -q

echo "--- 5. Création des vues ---"
cat ../sql/04_views.sql | sudo -u postgres psql -d novabank -q

echo "--- 6. Création des index ---"
cat ../sql/05_indexes.sql | sudo -u postgres psql -d novabank -q

echo "--- 7. Création des triggers ---"
cat ../sql/06_triggers.sql | sudo -u postgres psql -d novabank -q

echo "--- 8. Création des procédures ---"
cat ../sql/07_procedures.sql | sudo -u postgres psql -d novabank -q

echo "✅ Déploiement terminé avec succès !"

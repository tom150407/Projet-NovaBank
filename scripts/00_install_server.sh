#!/bin/bash
# Projet NovaBank - étape 1

echo "---Mise à jour du système ---"
sudo apt update && sudo apt upgrade -y

echo "--- Installasion de PostgreSQL ---"
sudo apt install postgresql postgresql-contrib -y

echo "--- Configuration du pare-feu (UFW) ---"
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow --force enable

echo "--- Sécurisation des accès (pg_hba.conf) ---"
PG_HBA=$(sudo -u postgres psql -t -P format=unaligned -c 'show hba_file;')
echo "Fichier de configuration trouvé : $PG_HBA"
sudo grep -v "^#" $PG_HBA | grep -v "^$"

echo "--- Redémarrage et vérificationde PostgreSQL ---"
sudo systemctl restart postgresql
sudo systemctl status postgresql --no-pager | grep "Active:"

echo "Installation terminé ! Le serveur est sécurisé."

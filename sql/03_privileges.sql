-- Nettoyage au cas où on relance le script
DROP ROLE IF EXISTS analyste, support, appli, auditeur;

-- 1. Création des 4 rôles
CREATE ROLE appli WITH LOGIN;
CREATE ROLE analyste WITH LOGIN;
CREATE ROLE support WITH LOGIN;
CREATE ROLE auditeur WITH LOGIN;

-- Bloquer l'accès public par défaut (sécurité de base)
REVOKE ALL ON SCHEMA core FROM PUBLIC;
REVOKE ALL ON SCHEMA audit FROM PUBLIC;

-- ==========================================
-- 2. Attribution des droits spécifiques
-- ==========================================

-- PROFIL 'appli' : L'application bancaire
-- Fait tourner la banque : peut lire, insérer, modifier, mais JAMAIS supprimer (DELETE interdit)
GRANT USAGE ON SCHEMA core, audit TO appli;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA core TO appli;
GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA audit TO appli;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA core, audit TO appli;

-- PROFIL 'analyste' : Data Analyst
-- Fait des statistiques : lecture seule sur les tables métier, pas d'accès à l'audit
GRANT USAGE ON SCHEMA core TO analyste;
GRANT SELECT ON ALL TABLES IN SCHEMA core TO analyste;

-- PROFIL 'support' : Service client
-- Aide les clients : accès uniquement aux clients, comptes et alertes (ne voit pas les transactions en direct)
GRANT USAGE ON SCHEMA core TO support;
GRANT SELECT ON core.customers, core.accounts, core.fraud_alerts TO support;
-- On lui donne le droit de modifier le statut d'une alerte ou les infos d'un client
GRANT UPDATE (phone, email) ON core.customers TO support;
GRANT UPDATE (status) ON core.fraud_alerts TO support;

-- PROFIL 'auditeur' : Contrôleur financier/sécurité
-- Vérifie tout : lecture seule absolue sur toutes les tables et l'historique d'audit
GRANT USAGE ON SCHEMA core, audit TO auditeur;
GRANT SELECT ON ALL TABLES IN SCHEMA core TO auditeur;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO auditeur;

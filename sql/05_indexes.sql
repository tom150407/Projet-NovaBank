-- 1. Index sur l'ID du client dans les comptes (pour trouver vite les comptes d'un client)
CREATE INDEX idx_accounts_customer ON core.accounts(customer_id);

-- 2. Index sur l'ID du compte dans le grand livre (très utile pour l'historique d'un compte)
CREATE INDEX idx_transactions_account ON core.transactions(account_id);

-- 3. Index sur la date des transactions (pour générer les relevés mensuels rapidement)
CREATE INDEX idx_transactions_date ON core.transactions(created_at);

-- 4. Index sur la date de création des alertes de fraude (pour trier les plus récentes)
CREATE INDEX idx_alerts_created_at ON core.fraud_alerts(created_at);

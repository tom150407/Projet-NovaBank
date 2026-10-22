-- ==========================================
-- 1. Vue qui cache des données (Masquage)
-- ==========================================
CREATE OR REPLACE VIEW core.vw_customer_support AS
SELECT 
    customer_id,
    first_name,
    LEFT(last_name, 1) || '***' AS masked_last_name,
    status
FROM core.customers c
JOIN core.accounts a ON c.customer_id = a.customer_id;

-- ==========================================
-- 2. Vue modifiable avec limite (CHECK OPTION)
-- ==========================================
CREATE OR REPLACE VIEW core.vw_open_fraud_alerts AS
SELECT alert_id, account_id, tx_id, rule_code, status, created_at
FROM core.fraud_alerts
WHERE status = 'OPEN'
WITH LOCAL CHECK OPTION; 
-- WITH LOCAL CHECK OPTION empêche l'insertion ou la modification si le statut n'est pas 'OPEN'

-- ==========================================
-- 3. Vue matérialisée (Enregistrée en dur)
-- ==========================================
CREATE MATERIALIZED VIEW core.mv_account_stats AS
SELECT 
    account_id, 
    COUNT(tx_id) AS total_transactions,
    SUM(amount) AS total_volume_exchanged
FROM core.transactions
GROUP BY account_id;

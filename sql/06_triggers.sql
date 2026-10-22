-- ==========================================
-- 1. Le solde se met à jour tout seul
-- ==========================================
CREATE OR REPLACE FUNCTION core.update_balance() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tx_type = 'CREDIT' THEN
        UPDATE core.accounts SET balance = balance + NEW.amount WHERE account_id = NEW.account_id;
    ELSIF NEW.tx_type = 'DEBIT' THEN
        UPDATE core.accounts SET balance = balance - NEW.amount WHERE account_id = NEW.account_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_balance
AFTER INSERT ON core.transactions
FOR EACH ROW EXECUTE FUNCTION core.update_balance();

-- ==========================================
-- 2. Le passé ne change plus (Grand livre immuable)
-- ==========================================
CREATE OR REPLACE FUNCTION core.prevent_modification() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Interdit : L''historique des transactions ne peut pas être modifié ni supprimé.';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_immutable_transactions
BEFORE UPDATE OR DELETE ON core.transactions
FOR EACH ROW EXECUTE FUNCTION core.prevent_modification();

-- ==========================================
-- 3. Détection des fraudes (Retrait > 5000 ou 5 virements en 10 min)
-- ==========================================
CREATE OR REPLACE FUNCTION core.detect_fraud() RETURNS TRIGGER AS $$
DECLARE
    recent_tx_count INT;
BEGIN
    -- Règle 1 : Montant anormal (>= 5000)
    IF NEW.amount >= 5000 THEN
        INSERT INTO core.fraud_alerts (account_id, tx_id, rule_code)
        VALUES (NEW.account_id, NEW.tx_id, 'LARGE_AMOUNT');
    END IF;

    -- Règle 2 : Fréquence anormale (5 transactions en 10 minutes)
    SELECT COUNT(*) INTO recent_tx_count
    FROM core.transactions
    WHERE account_id = NEW.account_id 
    AND created_at >= (CURRENT_TIMESTAMP - INTERVAL '10 minutes');

    IF recent_tx_count >= 5 THEN
        INSERT INTO core.fraud_alerts (account_id, tx_id, rule_code)
        VALUES (NEW.account_id, NEW.tx_id, 'HIGH_FREQUENCY');
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_detect_fraud
AFTER INSERT ON core.transactions
FOR EACH ROW EXECUTE FUNCTION core.detect_fraud();

-- ==========================================
-- 4. Journal d'audit automatique (Changements importants)
-- ==========================================
CREATE OR REPLACE FUNCTION audit.log_changes() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO audit.audit_log (table_name, operation, old_data, new_data, db_user)
        VALUES (TG_TABLE_NAME, 'UPDATE', row_to_json(OLD), row_to_json(NEW), current_user);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit.audit_log (table_name, operation, old_data, db_user)
        VALUES (TG_TABLE_NAME, 'DELETE', row_to_json(OLD), current_user);
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- On surveille les modifications sur les clients et les comptes
CREATE TRIGGER trg_audit_customers
AFTER UPDATE OR DELETE ON core.customers
FOR EACH ROW EXECUTE FUNCTION audit.log_changes();

CREATE TRIGGER trg_audit_accounts
AFTER UPDATE OR DELETE ON core.accounts
FOR EACH ROW EXECUTE FUNCTION audit.log_changes();

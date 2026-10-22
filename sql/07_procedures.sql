-- ==========================================
-- 1. Procédure : Virement bancaire sécurisé (Tout ou Rien)
-- ==========================================
CREATE OR REPLACE PROCEDURE core.make_transfer(
    p_from_account INT,
    p_to_account INT,
    p_amount NUMERIC,
    p_label TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_transfer_id INT;
    v_balance_from NUMERIC;
    v_balance_to NUMERIC;
BEGIN
    -- Vérification de base
    IF p_amount <= 0 THEN
        RAISE EXCEPTION 'Le montant doit être positif.';
    END IF;

    -- Calcul des nouveaux soldes
    SELECT balance - p_amount INTO v_balance_from FROM core.accounts WHERE account_id = p_from_account;
    SELECT balance + p_amount INTO v_balance_to FROM core.accounts WHERE account_id = p_to_account;

    -- L'opération s'arrête ici automatiquement si le solde devient négatif (grâce à notre contrainte CHECK sur la table)

    -- 1. Enregistrer le virement
    INSERT INTO core.transfers (from_account_id, to_account_id, amount, label)
    VALUES (p_from_account, p_to_account, p_amount, p_label)
    RETURNING transfer_id INTO v_transfer_id;

    -- 2. Créer l'écriture de débit (expéditeur)
    INSERT INTO core.transactions (account_id, tx_type, amount, balance_after, transfer_id)
    VALUES (p_from_account, 'DEBIT', p_amount, v_balance_from, v_transfer_id);

    -- 3. Créer l'écriture de crédit (destinataire)
    INSERT INTO core.transactions (account_id, tx_type, amount, balance_after, transfer_id)
    VALUES (p_to_account, 'CREDIT', p_amount, v_balance_to, v_transfer_id);

    -- Si on arrive ici sans erreur, on valide tout définitivement !
    COMMIT;
END;
$$;

-- ==========================================
-- 2. Procédure : Ouverture d'un compte
-- ==========================================
CREATE OR REPLACE PROCEDURE core.open_account(
    p_customer_id INT,
    p_type VARCHAR,
    p_initial_deposit NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_iban VARCHAR;
BEGIN
    -- Génération d'un faux IBAN aléatoire pour l'exemple
    v_iban := 'FR76' || LPAD(CAST(TRUNC(RANDOM() * 1000000000000000000000000) AS VARCHAR), 23, '0');
    
    INSERT INTO core.accounts (customer_id, iban, account_type, balance)
    VALUES (p_customer_id, v_iban, p_type, p_initial_deposit);
    
    COMMIT;
END;
$$;

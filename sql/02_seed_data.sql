-- 1. Création de 2 faux clients
INSERT INTO core.customers (first_name, last_name, email, birth_date)
VALUES 
('Alice', 'Dupont', 'alice@novabank.fr', '1990-05-14'),
('Bob', 'Martin', 'bob@novabank.fr', '1985-11-22');

-- 2. Création de 2 faux comptes avec un gros solde pour supporter les tests
INSERT INTO core.accounts (customer_id, iban, account_type, balance)
VALUES 
(1, 'FR7600000000000000000000001', 'COURANT', 10000000.00),
(2, 'FR7600000000000000000000002', 'COURANT', 10000000.00);

-- 3. Génération de 500 000 virements (de Alice vers Bob)
INSERT INTO core.transfers (from_account_id, to_account_id, amount, label)
SELECT 1, 2, 10.00, 'Virement de test ' || i
FROM generate_series(1, 500000) AS i;

-- 4. Génération de 500 000 écritures de DEBIT pour Alice
INSERT INTO core.transactions (account_id, tx_type, amount, balance_after, transfer_id)
SELECT 1, 'DEBIT', 10.00, 10000000.00 - (i * 10), i
FROM generate_series(1, 500000) AS i;

-- 5. Génération de 500 000 écritures de CREDIT pour Bob
INSERT INTO core.transactions (account_id, tx_type, amount, balance_after, transfer_id)
SELECT 2, 'CREDIT', 10.00, 10000000.00 + (i * 10), i
FROM generate_series(1, 500000) AS i;

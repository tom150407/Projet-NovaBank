-- Création des schémas
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS audit;

-- 1. Table des clients
CREATE TABLE core.customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL CHECK (email LIKE '%@%'),
    phone VARCHAR(20),
    birth_date DATE NOT NULL CHECK (birth_date <= CURRENT_DATE - INTERVAL '18 years'),
    kyc_status VARCHAR(20) DEFAULT 'PENDING',
    risk_level VARCHAR(20) DEFAULT 'LOW',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Table des comptes
CREATE TABLE core.accounts (
    account_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES core.customers(customer_id),
    iban VARCHAR(34) UNIQUE NOT NULL,
    account_type VARCHAR(50) NOT NULL,
    balance NUMERIC(15,2) NOT NULL DEFAULT 0.00 CHECK (balance >= 0),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Table des virements
CREATE TABLE core.transfers (
    transfer_id SERIAL PRIMARY KEY,
    from_account_id INT REFERENCES core.accounts(account_id),
    to_account_id INT REFERENCES core.accounts(account_id),
    amount NUMERIC(15,2) NOT NULL CHECK (amount > 0),
    label TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (from_account_id != to_account_id)
);

-- 4. Table des écritures (Grand livre)
CREATE TABLE core.transactions (
    tx_id SERIAL PRIMARY KEY,
    account_id INT REFERENCES core.accounts(account_id),
    tx_type VARCHAR(10) NOT NULL CHECK (tx_type IN ('CREDIT', 'DEBIT')),
    amount NUMERIC(15,2) NOT NULL,
    balance_after NUMERIC(15,2) NOT NULL,
    transfer_id INT REFERENCES core.transfers(transfer_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Table des alertes de fraude
CREATE TABLE core.fraud_alerts (
    alert_id SERIAL PRIMARY KEY,
    account_id INT REFERENCES core.accounts(account_id),
    tx_id INT REFERENCES core.transactions(tx_id),
    rule_code VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'OPEN',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Table du journal d'audit
CREATE TABLE audit.audit_log (
    log_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    operation VARCHAR(10) NOT NULL,
    old_data JSONB,
    new_data JSONB,
    db_user VARCHAR(50) NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

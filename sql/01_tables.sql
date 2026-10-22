-- Création des schémas
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS audit;

-- &. Table des clients
CREATE TABLE core.customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email varchar(255) UNIQUE NOT NULL CHECK (email LIKE '%@%'),
    phone VARCHAR(20),
    birth_date DATE NOT NULL CHECK (birth_date <= CURRENT_DATE - INTERVAL '18 years'),
    kyc_status VARCHAR(20) DEFAULT 'PENDING',
    risk_level VARCHAR(20) DEFAULT 'LOW',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

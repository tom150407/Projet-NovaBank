-- ==========================================
-- TESTS DE LA BANQUE NOVABANK
-- ==========================================

-- 1. Test d'ouverture de compte (Procédure)
CALL core.open_account(1, 'EPARGNE', 500.00);

-- 2. Test d'un virement valide (Procédure)
-- Alice (1) envoie 100 à Bob (2)
CALL core.make_transfer(1, 2, 100.00, 'Remboursement resto');

-- 3. Test de détection de fraude (Trigger)
-- Alice tente d'envoyer un montant énorme (doit créer une alerte OPEN)
CALL core.make_transfer(1, 2, 6000.00, 'Achat voiture');

-- 4. Vérification des alertes générées
SELECT * FROM core.fraud_alerts;

-- 5. TEST D'ÉCHEC 1 : Virement négatif (doit être refusé)
-- CALL core.make_transfer(1, 2, -50.00, 'Tentative de vol');

-- 6. TEST D'ÉCHEC 2 : Modification du passé (doit être refusé par le trigger)
-- UPDATE core.transactions SET amount = 9999 WHERE tx_id = 1;

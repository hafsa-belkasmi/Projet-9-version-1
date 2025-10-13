@IsTest
private class CalculMontantTriggerTest {

    /**
     * Méthode de test principale.
     * Valide le comportement du trigger avant insert et avant update
     * pour la formule : NetAmount__c = TotalAmount__c - ShipmentCost__c.
     */
    @IsTest
    static void before_insert_and_update_sets_netamount() {

        // ---- Préparation des données de test ----
        Commande__c c = new Commande__c();
        // Renseigne ici les champs obligatoires si votre objet en a
        // c.Name = 'Test 1';

        c.TotalAmount__c = 100;
        c.ShipmentCost__c = 20;

        // ---- Exécution du scénario "before insert" ----
        insert c;

        // ---- Vérification post-insertion ----
        // NetAmount doit être 100 - 20 = 80
        c = [SELECT NetAmount__c FROM Commande__c WHERE Id = :c.Id];
        System.assertEquals(80, (Decimal)c.NetAmount__c,
            'Le montant net doit être égal à 100 - 20 après insertion.');

        // ---- Scénario "before update" ----
        // On modifie les montants pour vérifier que le calcul se met bien à jour.
        c.TotalAmount__c = 80;
        c.ShipmentCost__c = 40;
        update c;

        // ---- Vérification post-mise à jour ----
        // NetAmount doit être 80 - 40 = 40
        c = [SELECT NetAmount__c FROM Commande__c WHERE Id = :c.Id];
        System.assertEquals(40, (Decimal)c.NetAmount__c,
            'Le montant net doit être recalculé correctement après update (80 - 40).');
    }
}

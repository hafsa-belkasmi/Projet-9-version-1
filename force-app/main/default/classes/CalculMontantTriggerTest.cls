/**
 * Classe de test unitaire pour le trigger CalculMontantTrigger.
 * Objectif : vérifier que le champ NetAmount__c est correctement calculé
 * lors des opérations d'insertion et de mise à jour sur l'objet Commande__c.
 */
@IsTest
private class CalculMontantTriggerTest {
    
    /**
     * Méthode de test principale.
     * Valide le comportement du trigger avant insert et avant update.
     */
    @IsTest
    static void before_insert_and_update_sets_netamount() {
        
        // --- Préparation des données de test ---
        Commande__c c = new Commande__c();
        // Si l’objet possède un champ Name obligatoire, on peut le renseigner ici :
        // c.Name = 'Test 1';
        // Sinon, il peut être laissé vide pour ce test.
        c.TotalAmount__c   = 100;
        c.ShipmentCost__c  = 20;
        
        // --- Exécution du scénario "before insert" ---
        insert c;
        
        // --- Vérification post-insertion ---
        // On récupère l’enregistrement inséré pour valider le calcul du NetAmount__c.
        c = [SELECT NetAmount__c FROM Commande__c WHERE Id = :c.Id];
        System.assertEquals(120, (Decimal)c.NetAmount__c, 
            'Le montant net doit être égal à 100 + 20 après insertion.');
        
        // --- Scénario "before update" ---
        // On modifie les montants pour vérifier que le calcul se met bien à jour.
        c.TotalAmount__c  = 80;
        c.ShipmentCost__c = 40;
        update c;
        
        // --- Vérification post-mise à jour ---
        // Le montant net doit à nouveau être recalculé (80 + 40 = 120).
        c = [SELECT NetAmount__c FROM Commande__c WHERE Id = :c.Id];
        System.assertEquals(120, (Decimal)c.NetAmount__c, 
            'Le montant net doit être recalculé correctement après update (80 + 40).');
    }
}

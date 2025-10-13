@IsTest
private class UpdateAllAccountsTest {

    /**
     * Méthode de test principale : testBatchExecution
     *
     * Objectif :
     *  - Tester l’exécution complète du batch UpdateAllAccounts.
     *  - Vérifier que le champ AnnualRevenue est mis à jour
     *    à partir de la somme des NetAmount__c (calculés par trigger :
     *    TotalAmount__c - ShipmentCost__c).
     */
    @IsTest
    static void testBatchExecution() {
        // --- Préparation des données de test ---
        Account acc = new Account(Name = 'Batch Test');
        insert acc;

        // Insertion d'une commande liée au compte
        // Net attendu : 520 - 20 = 500
        insert new Commande__c(
            Compte__c       = acc.Id,
            TotalAmount__c  = 520,
            ShipmentCost__c = 20,
            Statut__c       = 'Activated'
        );

        // --- Exécution du batch ---
        Test.startTest();
        Database.executeBatch(new UpdateAllAccounts(), 200);
        Test.stopTest();

        // --- Vérification du résultat ---
        Account refreshed = [SELECT AnnualRevenue FROM Account WHERE Id = :acc.Id];
        System.assertEquals(
            500,
            (Decimal)refreshed.AnnualRevenue,
            'Le champ AnnualRevenue doit être mis à jour correctement par le batch (520 - 20 = 500).'
        );
    }
}

@IsTest
private class UpdateAccountCAHandlerTest {

    /**
     * Test principal : valide que le recalcul met bien à jour le champ AnnualRevenue
     * du compte avec la somme totale des NetAmount__c de ses commandes.
     * (NetAmount__c est calculé par le trigger : TotalAmount__c - ShipmentCost__c)
     */
    @IsTest
    static void recalc_sets_annual_revenue() {
        // --- Préparation des données ---
        Account acc = new Account(Name = 'Test');
        insert acc;

        // --- Insertion de deux commandes liées au compte ---
        // Net attendus : (100 - 20) = 80 et (60 - 20) = 40 => total 120
        insert new List<Commande__c>{
            new Commande__c(
                Compte__c       = acc.Id,
                TotalAmount__c  = 100,
                ShipmentCost__c = 20,
                Statut__c       = 'Activated'
            ),
            new Commande__c(
                Compte__c       = acc.Id,
                TotalAmount__c  = 60,
                ShipmentCost__c = 20,
                Statut__c       = 'Activated'
            )
        };

        // --- Exécution du traitement testé ---
        Test.startTest();
        UpdateAccountCAHandler.recalcRevenueForAccounts(new Set<Id>{ acc.Id });
        Test.stopTest();

        // --- Vérification du résultat ---
        Account refreshed = [SELECT AnnualRevenue FROM Account WHERE Id = :acc.Id];
        System.assertEquals(
            120,
            (Decimal)refreshed.AnnualRevenue,
            'AnnualRevenue doit égaler la somme des NetAmount__c ((100-20) + (60-20) = 120).'
        );
    }
}

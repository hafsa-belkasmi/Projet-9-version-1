@IsTest
private class MyTeamOrdersControllerTest {

    /**
     * Méthode de test principale.
     * Valide les deux méthodes de calcul des montants totaux et "Activated",
     * en laissant le trigger calculer NetAmount__c = TotalAmount__c - ShipmentCost__c.
     */
    @IsTest
    static void sum_all_and_activated() {
        // --- Préparation des données ---
        Account acc = new Account(Name = 'ACC TEST');
        insert acc;

        // --- Création des commandes ---
        // 2 commandes avec statut "Activated"
        // 1) 100 - 20 = 80
        insert new Commande__c(
            Compte__c      = acc.Id,
            TotalAmount__c = 100,
            ShipmentCost__c= 20,
            Statut__c      = 'Activated'
        );
        // 2) 60 - 20 = 40
        insert new Commande__c(
            Compte__c      = acc.Id,
            TotalAmount__c = 60,
            ShipmentCost__c= 20,
            Statut__c      = 'Activated'
        );

        // 1 commande "Draft" : 70 - 20 = 50
        // (Comptée seulement dans la somme TOTALE)
        insert new Commande__c(
            Compte__c      = acc.Id,
            TotalAmount__c = 70,
            ShipmentCost__c= 20,
            Statut__c      = 'Draft'
        );

        // --- Exécution du test ---
        Test.startTest();
        Decimal totalALL        = MyTeamOrdersController.getSumOrdersByAccount(acc.Id);              // 80 + 40 + 50 = 170
        Decimal totalActivated  = MyTeamOrdersController.getSumActivatedOrdersByAccount(acc.Id);     // 80 + 40 = 120
        Test.stopTest();

        // --- Vérifications ---
        System.assertEquals(170, totalALL,       'Somme totale attendue : 170');
        System.assertEquals(120, totalActivated, 'Somme Activated attendue : 120');
    }
}

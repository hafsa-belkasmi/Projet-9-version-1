/**
 * Classe de test unitaire pour MyTeamOrdersController.
 * 
 * Objectif :
 *   Vérifier le bon fonctionnement des méthodes de calcul de sommes :
 *   - getSumOrdersByAccount() : total des commandes, tous statuts confondus.
 *   - getSumActivatedOrdersByAccount() : total uniquement des commandes avec le statut "Activated".
 * 
 * Bonnes pratiques :
 *   - Les données de test sont créées localement dans la méthode.
 *   - Les tests utilisent Test.startTest() / Test.stopTest() pour isoler l’exécution.
 */
@IsTest
private class MyTeamOrdersControllerTest {
    
    /**
     * Méthode de test principale.
     * Valide les deux méthodes de calcul des montants totaux et "Activated".
     */
    @IsTest
    static void sum_all_and_activated() {
        // --- Préparation des données ---
        // Création d’un compte test pour associer les commandes
        Account acc = new Account(Name = 'ACC TEST');
        insert acc;

        // --- Création des commandes ---
        // 2 commandes avec statut "Activated" : total attendu = 100 + 20 = 120
        insert new Commande__c(Compte__c = acc.Id, NetAmount__c = 100, Statut__c = 'Activated');
        insert new Commande__c(Compte__c = acc.Id, NetAmount__c = 20,  Statut__c = 'Activated');

        // 1 commande avec statut "Draft" : total = 50
        // Cette commande est incluse uniquement dans la somme TOTALE.
        insert new Commande__c(Compte__c = acc.Id, NetAmount__c = 50,  Statut__c = 'Draft');

        // --- Exécution du test ---
        Test.startTest();
        Decimal totalAll = MyTeamOrdersController.getSumOrdersByAccount(acc.Id);
        Decimal totalActivated = MyTeamOrdersController.getSumActivatedOrdersByAccount(acc.Id);
        Test.stopTest();

        // --- Vérifications ---
        // Vérifie que la somme totale inclut toutes les commandes : 100 + 20 + 50 = 170
        System.assertEquals(170, totalAll, 'Somme totale attendue : 170');

        // Vérifie que la somme "Activated" ne prend que les commandes actives : 100 + 20 = 120
        System.assertEquals(120, totalActivated, 'Somme Activated attendue : 120');
    }
}

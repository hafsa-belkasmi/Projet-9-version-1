@IsTest
private class MyTeamOrdersControllerTest {
    @IsTest
    static void sum_all_and_activated() {
        Account acc = new Account(Name = 'ACC TEST');
        insert acc;

        // 2 commandes "Activated" : 100 + 20 = 120
        insert new Commande__c(Compte__c = acc.Id, NetAmount__c = 100, Statut__c = 'Activated');
        insert new Commande__c(Compte__c = acc.Id, NetAmount__c = 20,  Statut__c = 'Activated');

        // 1 commande "Draft" : 50 (comptée seulement dans la somme TOTALE)
        insert new Commande__c(Compte__c = acc.Id, NetAmount__c = 50,  Statut__c = 'Draft');

        Test.startTest();
        Decimal totalAll = MyTeamOrdersController.getSumOrdersByAccount(acc.Id);
        Decimal totalActivated = MyTeamOrdersController.getSumActivatedOrdersByAccount(acc.Id);
        Test.stopTest();

        System.assertEquals(170, totalAll, 'Somme totale attendue : 170');
        System.assertEquals(120, totalActivated, 'Somme Activated attendue : 120');
    }
}

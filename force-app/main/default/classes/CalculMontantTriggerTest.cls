@IsTest
private class CalculMontantTriggerTest {
    @IsTest
    static void before_insert_and_update_sets_netamount() {
        Commande__c c = new Commande__c();
        // Si ton objet a un champ "Name" standard, mettre c.Name = 'Test 1';
        // Sinon laisse vide, ce n'est pas bloquant pour le test.
        c.TotalAmount__c   = 100;
        c.ShipmentCost__c  = 20;
        insert c;

        c = [SELECT NetAmount__c FROM Commande__c WHERE Id = :c.Id];
        System.assertEquals(120, (Decimal)c.NetAmount__c, 'Net = 100 + 20');

        // Vérifie aussi à l’update
        c.TotalAmount__c  = 80;
        c.ShipmentCost__c = 40;
        update c;

        c = [SELECT NetAmount__c FROM Commande__c WHERE Id = :c.Id];
        System.assertEquals(120, (Decimal)c.NetAmount__c, 'Net recalculé à l’update (80 + 40)');
    }
}

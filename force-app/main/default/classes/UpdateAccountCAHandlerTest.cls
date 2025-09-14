@IsTest
private class UpdateAccountCAHandlerTest {

    @IsTest
    static void recalc_sets_annual_revenue() {
        Account acc = new Account(Name = 'Test');
        insert acc;

        insert new List<Commande__c>{
            new Commande__c(Compte__c = acc.Id, NetAmount__c = 80),
            new Commande__c(Compte__c = acc.Id, NetAmount__c = 40)
        };

        Test.startTest();
        UpdateAccountCAHandler.recalcRevenueForAccounts(new Set<Id>{ acc.Id });
        Test.stopTest();

        Account refreshed = [SELECT AnnualRevenue FROM Account WHERE Id = :acc.Id];
        System.assertEquals(120, (Decimal)refreshed.AnnualRevenue,
            'AnnualRevenue doit égaler la somme des NetAmount__c');
    }
}

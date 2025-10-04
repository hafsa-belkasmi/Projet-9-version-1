@IsTest
private class UpdateAllAccountsTest {
  @IsTest
  static void bulk_update_sets_revenue() {
    Account acc = new Account(Name = 'Test Account 1'); insert acc;

    insert new List<Commande__c>{
      new Commande__c(Compte__c = acc.Id, NetAmount__c = 80, Statut__c = 'Activated'),
      new Commande__c(Compte__c = acc.Id, NetAmount__c = 40, Statut__c = 'Activated')
    };

    Test.startTest();
    UpdateAllAccounts.updateAccounts(new List<Id>{ acc.Id });
    Test.stopTest();

    Account refreshed = [SELECT AnnualRevenue FROM Account WHERE Id = :acc.Id];
    System.assertEquals(120, (Decimal)refreshed.AnnualRevenue,
      'AnnualRevenue doit égaler la somme des NetAmount__c');
  }
}

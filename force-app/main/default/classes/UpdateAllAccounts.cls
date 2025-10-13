/**
 * Batch Apex : UpdateAllAccounts
 * Recalcule AnnualRevenue pour tous les comptes en agrégeant NetAmount__c
 * (NetAmount__c = TotalAmount__c - ShipmentCost__c, calculé par le trigger).
 */
public with sharing class UpdateAllAccounts implements Database.Batchable<SObject> {

    // START : sélectionne tous les comptes à traiter (ids uniquement)
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id FROM Account WHERE Id != null
        ]);
    }

    // EXECUTE : traite un lot de comptes
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        if (scope == null || scope.isEmpty()) return;

        Set<Id> accountIds = new Set<Id>();
        for (Account acc : scope) accountIds.add(acc.Id);

        // Délégué au handler (agrège NetAmount__c et met à jour AnnualRevenue)
        UpdateAccountCAHandler.recalcRevenueForAccounts(accountIds);
    }

    // FINISH : hook de fin (logs / notifications si besoin)
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch terminé avec succès pour la mise à jour des comptes.');
    }
}

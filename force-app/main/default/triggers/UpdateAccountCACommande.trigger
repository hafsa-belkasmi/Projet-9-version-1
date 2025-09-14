trigger UpdateAccountCACommande on Commande__c (
    after insert, after update, after delete, after undelete
) {
    Set<Id> accountIds = new Set<Id>();

    if (Trigger.isInsert || Trigger.isUpdate) {
        for (Commande__c row : Trigger.new) {
            if (row.Compte__c != null) accountIds.add(row.Compte__c);
        }
    }
    if (Trigger.isDelete) {
        for (Commande__c row : Trigger.old) {
            if (row.Compte__c != null) accountIds.add(row.Compte__c);
        }
    }

    if (!accountIds.isEmpty()) {
        UpdateAccountCAHandler.recalcRevenueForAccounts(accountIds);
    }
}

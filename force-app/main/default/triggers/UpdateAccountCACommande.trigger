trigger UpdateAccountCACommande on Commande__c (after insert, after update, after delete, after undelete) {
    Set<Id> accountIds = new Set<Id>();
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (Commande__c c : Trigger.new) if (c.Compte__c != null) accountIds.add(c.Compte__c);
    }
    if (Trigger.isDelete) {
        for (Commande__c c : Trigger.old) if (c.Compte__c != null) accountIds.add(c.Compte__c);
    }
    if (!accountIds.isEmpty()) UpdateAccountCAHandler.recalcRevenueForAccounts(accountIds);
}

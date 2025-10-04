public without sharing class UpdateAccountCAHandler {

    // Nom appelé par les tests/classes
    public static void recalcRevenueForAccounts(Set<Id> accountIds) {
        recalcAnnualRevenue(accountIds);
    }

    // Somme TOTALE (aucun filtre sur Statut__c)
    public static void recalcAnnualRevenue(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) return;

        Map<Id, Decimal> sumsByAccount = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT Compte__c acc, SUM(NetAmount__c) total
            FROM Commande__c
            WHERE Compte__c IN :accountIds
            GROUP BY Compte__c
        ]) {
            sumsByAccount.put((Id) ar.get('acc'), (Decimal) ar.get('total'));
        }

        List<Account> toUpdate = new List<Account>();
        for (Id accId : accountIds) {
            Decimal total = sumsByAccount.containsKey(accId) ? (Decimal) sumsByAccount.get(accId) : 0;
            toUpdate.add(new Account(Id = accId, AnnualRevenue = total));
        }
        if (!toUpdate.isEmpty()) update toUpdate;
    }
}

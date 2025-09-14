public with sharing class UpdateAccountCAHandler {

    /**
     * Recalcule le CA (somme des NetAmount__c des Commande__c) pour les comptes donnés
     * et l'écrit dans Account.AnnualRevenue.
     */
    public static void recalcRevenueForAccounts(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) return;

        // 1) Agréger les NetAmount par compte
        Map<Id, Decimal> revenueByAccount = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT Compte__c accId, SUM(NetAmount__c) total
            FROM Commande__c
            WHERE Compte__c IN :accountIds
            GROUP BY Compte__c
        ]) {
            revenueByAccount.put((Id) ar.get('accId'), (Decimal) ar.get('total'));
        }

        // 2) Appliquer la valeur (0 si aucune commande)
        List<Account> toUpdate = new List<Account>();
        for (Id accId : accountIds) {
            Decimal total = revenueByAccount.get(accId);
            toUpdate.add(new Account(
                Id = accId,
                AnnualRevenue = (total == null) ? 0 : total
            ));
        }

        if (!toUpdate.isEmpty()) update toUpdate;
    }
}

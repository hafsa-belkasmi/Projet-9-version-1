/**
 * Classe utilitaire responsable du recalcul du chiffre d’affaires (AnnualRevenue)
 * sur les comptes, à partir des montants nets des commandes (Commande__c).
 *
 * Important :
 *  - Le champ NetAmount__c est calculé par le trigger :
 *      NetAmount__c = TotalAmount__c - ShipmentCost__c
 *  - Ici on agrège simplement les NetAmount__c par compte.
 *
 * Design :
 *  - "without sharing" : exécute sans les règles de partage (utile pour un recalcul global).
 *  - Appelée par un trigger après DML (insert/update/delete/undelete).
 *  - Bulk-safe : agrégations SOQL et updates groupés.
 */
public without sharing class UpdateAccountCAHandler {

    /** Point d’entrée public (utilisé par le trigger et les tests) */
    public static void recalcRevenueForAccounts(Set<Id> accountIds) {
        recalcAnnualRevenue(accountIds);
    }

    /**
     * Recalcule AnnualRevenue de chaque compte fourni,
     * en additionnant les NetAmount__c de toutes ses commandes, sans filtrer le statut.
     */
    public static void recalcAnnualRevenue(Set<Id> accountIds) {
        // Garde-fou
        if (accountIds == null || accountIds.isEmpty()) return;

        // 1) Agréger les NetAmount__c par compte
        Map<Id, Decimal> sumsByAccount = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT Compte__c acc, SUM(NetAmount__c) total
            FROM Commande__c
            WHERE Compte__c IN :accountIds
            GROUP BY Compte__c
        ]) {
            sumsByAccount.put((Id) ar.get('acc'), (Decimal) ar.get('total'));
        }

        // 2) Préparer la mise à jour des comptes
        List<Account> toUpdate = new List<Account>();
        for (Id accId : accountIds) {
            Decimal total = sumsByAccount.containsKey(accId)
                ? (Decimal) sumsByAccount.get(accId)
                : 0;
            toUpdate.add(new Account(Id = accId, AnnualRevenue = total));
        }

        // 3) Update groupé
        if (!toUpdate.isEmpty()) update toUpdate;
    }
}

/*
 * =====================================================================
 * Trigger : CommandeTrigger
 * =====================================================================
 * Objectif :
 *  - Gérer en un seul trigger les opérations liées à Commande__c :
 *      1) Calcul automatique du champ NetAmount__c avant enregistrement.
 *      2) Recalcul du chiffre d’affaires des comptes après modification.
 *
 * Détails :
 *  - Calcul du montant net :
 *      NetAmount__c = TotalAmount__c - ShipmentCost__c
 *      Effectué en BEFORE INSERT / BEFORE UPDATE.
 *  - Recalcul du chiffre d’affaires :
 *      Délégué à UpdateAccountCAHandler après DML (INSERT, UPDATE, DELETE, UNDELETE).
 *
 * Bonnes pratiques :
 *  - Aucune requête DML directe dans le trigger.
 *  - Logique déléguée aux handlers pour maintenabilité.
 * =====================================================================
 */

trigger CommandeTrigger on Commande__c (
    before insert,
    before update,
    after insert,
    after update,
    after delete,
    after undelete
) {
    // ==========================================================
    // 1) Calcul du montant net (avant enregistrement)
    //    -> Recalculé à chaque insert/update
    // ==========================================================
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        for (Commande__c c : Trigger.new) {
            Decimal total = (c.TotalAmount__c  == null) ? 0 : c.TotalAmount__c;
            Decimal ship  = (c.ShipmentCost__c == null) ? 0 : c.ShipmentCost__c;
            c.NetAmount__c = total - ship; // soustraction correcte
        }
    }

    // ==========================================================
    // 2) Mise à jour du chiffre d’affaires (après DML)
    // ==========================================================
    if (Trigger.isAfter) {
        Set<Id> accountIds = new Set<Id>();

        // Cas Insert / Update / Undelete
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
            for (Commande__c c : Trigger.new) {
                if (c.Compte__c != null) accountIds.add(c.Compte__c);
            }
        }

        // Cas Delete
        if (Trigger.isDelete) {
            for (Commande__c c : Trigger.old) {
                if (c.Compte__c != null) accountIds.add(c.Compte__c);
            }
        }

        // Exécution du recalcul via le handler
        if (!accountIds.isEmpty()) {
            UpdateAccountCAHandler.recalcRevenueForAccounts(accountIds);
        }
    }
}

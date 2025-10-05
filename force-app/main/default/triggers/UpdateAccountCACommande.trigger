/**
 * ==============================================================
 * Trigger : UpdateAccountCACommande
 * ==============================================================
 * Objectif :
 *   - Recalculer automatiquement le chiffre d’affaires (AnnualRevenue)
 *     du ou des comptes liés à des commandes (Commande__c) lorsqu’elles
 *     sont insérées, mises à jour, supprimées ou restaurées.
 *
 * Détails :
 *   - Chaque opération sur Commande__c impacte potentiellement le total
 *     du compte parent (champ Compte__c).
 *   - Le recalcul est délégué à la classe utilitaire UpdateAccountCAHandler,
 *     qui gère l’agrégation et la mise à jour des comptes concernés.
 *
 * Événements :
 *   - after insert
 *   - after update
 *   - after delete
 *   - after undelete
 *     → Le trigger agit **après** les DML pour que les données de commandes
 *       soient bien disponibles et consolidées avant le recalcul.
 *
 * Bonnes pratiques :
 *   - Pas de DML ni de requêtes directes ici : tout est géré dans le handler.
 *   - Utilisation d’un Set<Id> pour éviter les doublons de comptes.
 *   - Gestion claire des cas Delete / Undelete via Trigger.old / Trigger.new.
 * ==============================================================
 */

trigger UpdateAccountCACommande on Commande__c (
    after insert,
    after update,
    after delete,
    after undelete
) {
    // Ensemble des Ids de comptes à recalculer
    Set<Id> accountIds = new Set<Id>();

    // --- Cas : Insert / Update / Undelete ---
    // Récupère les comptes liés dans Trigger.new
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (Commande__c c : Trigger.new) {
            if (c.Compte__c != null) accountIds.add(c.Compte__c);
        }
    }

    // --- Cas : Delete ---
    // Récupère les comptes liés dans Trigger.old
    if (Trigger.isDelete) {
        for (Commande__c c : Trigger.old) {
            if (c.Compte__c != null) accountIds.add(c.Compte__c);
        }
    }

    // --- Exécution du recalcul ---
    // Si au moins un compte est concerné, on appelle la logique métier centralisée
    if (!accountIds.isEmpty()) {
        UpdateAccountCAHandler.recalcRevenueForAccounts(accountIds);
    }
}

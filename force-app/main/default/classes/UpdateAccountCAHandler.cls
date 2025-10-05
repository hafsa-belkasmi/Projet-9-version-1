/**
 * Classe utilitaire responsable du recalcul du chiffre d’affaires (AnnualRevenue)
 * sur les comptes, à partir des montants totaux des commandes associées (Commande__c).
 *
 * Design :
 *  - "without sharing" : permet d'exécuter les mises à jour sans restriction de partage,
 *    utile si le recalcul doit s'appliquer à l’ensemble des comptes.
 *  - Utilisée par des triggers ou d'autres classes de gestion métier.
 *  - Le code effectue un regroupement par compte pour calculer la somme des NetAmount__c.
 */
public without sharing class UpdateAccountCAHandler {

    /**
     * Méthode publique appelée par les tests ou d'autres classes.
     * Sert d’entrée principale pour lancer le recalcul.
     *
     * @param accountIds Ensemble des Ids de comptes à recalculer
     */
    public static void recalcRevenueForAccounts(Set<Id> accountIds) {
        // Délègue la logique principale à la méthode interne
        recalcAnnualRevenue(accountIds);
    }

    /**
     * Recalcule le champ AnnualRevenue de chaque compte fourni,
     * en additionnant le NetAmount__c de toutes ses commandes (Commande__c),
     * sans appliquer de filtre sur le statut.
     *
     * @param accountIds Ensemble des Ids de comptes à traiter
     */
    public static void recalcAnnualRevenue(Set<Id> accountIds) {
        // Vérification défensive : pas de traitement si l’ensemble est nul ou vide
        if (accountIds == null || accountIds.isEmpty()) return;

        // --- Étape 1 : Regrouper les montants des commandes par compte ---
        Map<Id, Decimal> sumsByAccount = new Map<Id, Decimal>();

        // Requête d’agrégation : calcule la somme des NetAmount__c par compte
        for (AggregateResult ar : [
            SELECT Compte__c acc, SUM(NetAmount__c) total
            FROM Commande__c
            WHERE Compte__c IN :accountIds
            GROUP BY Compte__c
        ]) {
            // Stocke la somme totale par Id de compte
            sumsByAccount.put((Id) ar.get('acc'), (Decimal) ar.get('total'));
        }

        // --- Étape 2 : Préparer la mise à jour des comptes ---
        List<Account> toUpdate = new List<Account>();

        for (Id accId : accountIds) {
            // Si le compte a des commandes, on récupère la somme ; sinon, on met 0
            Decimal total = sumsByAccount.containsKey(accId)
                ? (Decimal) sumsByAccount.get(accId)
                : 0;
            
            // Création d’un enregistrement Account minimaliste pour mise à jour partielle
            toUpdate.add(new Account(Id = accId, AnnualRevenue = total));
        }

        // --- Étape 3 : Mise à jour en base ---
        // On effectue l’update uniquement si la liste n’est pas vide
        if (!toUpdate.isEmpty()) update toUpdate;
    }
}

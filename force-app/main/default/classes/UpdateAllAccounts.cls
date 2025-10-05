/**
 * Classe Apex utilitaire permettant de recalculer le chiffre d’affaires (AnnualRevenue)
 * pour une liste de comptes donnée, en s’appuyant sur la logique du handler
 * UpdateAccountCAHandler.
 *
 * Design :
 *  - "with sharing" : applique les règles de partage et de visibilité sur les comptes.
 *    Cela garantit que l’utilisateur n’agit que sur les enregistrements auxquels il a accès.
 *  - Cette classe sert de façade simple à utiliser depuis des composants LWC, 
 *    des tests unitaires ou d’autres classes métiers.
 */
public with sharing class UpdateAllAccounts {

    /**
     * Méthode utilitaire publique.
     * Permet de lancer le recalcul de l’AnnualRevenue pour une liste d’Ids de comptes.
     *
     * @param accountIds Liste des Ids de comptes à traiter.
     *                   Si la liste est vide ou nulle, aucun traitement n’est effectué.
     */
    public static void updateAccounts(List<Id> accountIds) {
        // Vérification défensive : on quitte si la liste est vide ou nulle.
        if (accountIds == null || accountIds.isEmpty()) return;

        // Délègue le recalcul au handler centralisé (gestion des agrégations et update).
        UpdateAccountCAHandler.recalcRevenueForAccounts(new Set<Id>(accountIds));
    }
}

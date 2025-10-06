/**
 * Classe batch Apex : UpdateAllAccounts
 * ------------------------------------------------------------
 * Cette classe permet de recalculer le chiffre d’affaires (AnnualRevenue)
 * de tous les comptes existants dans l’organisation Salesforce.
 *
 *  Objectif :
 *    - Automatiser la mise à jour du champ AnnualRevenue des comptes
 *      en fonction des montants des commandes associées.
 *    - Réutiliser la logique métier déjà implémentée dans la classe
 *      UpdateAccountCAHandler.
 *
 * Avantages :
 *    - Exécute le traitement par lots (batch) pour supporter un grand volume de données.
 *    - Garantit de meilleures performances et un traitement asynchrone.
 *    - Peut être planifié (Scheduler Apex) pour une mise à jour régulière.
 *
 *  Implémentations :
 *    - Implémente l’interface Database.Batchable<SObject> :
 *        • start()  → définit l’ensemble des enregistrements à traiter.
 *        • execute() → traite chaque lot d’enregistrements.
 *        • finish()  → exécute les actions finales après le traitement.
 *
 * Auteur  : Hafsa Belkasmi  
 * Date    : Octobre 2025  
 * Version : 1.0
 */
public with sharing class UpdateAllAccounts implements Database.Batchable<SObject> {

    /**
     * Méthode START
     * ------------------------------------------------------------
     * Objectif :
     *   - Sélectionne tous les comptes à inclure dans le batch.
     *   - Cette requête retourne un QueryLocator, permettant à Salesforce
     *     de traiter de très gros volumes (jusqu’à 50 millions d’enregistrements).
     *
     * @param bc Contexte du batch (fourni automatiquement par Salesforce)
     * @return Un Database.QueryLocator contenant les comptes à traiter.
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Sélection de tous les comptes à mettre à jour
        return Database.getQueryLocator([
            SELECT Id FROM Account WHERE Id != null
        ]);
    }

    /**
     * Méthode EXECUTE
     * ------------------------------------------------------------
     * Objectif :
     *   - Reçoit un sous-ensemble de comptes (scope) à traiter.
     *   - Extrait les Ids de ces comptes et appelle la méthode
     *     "recalcRevenueForAccounts" du handler pour mettre à jour
     *     le champ AnnualRevenue.
     *
     * Détails :
     *   - Cette méthode est exécutée plusieurs fois (par lots).
     *   - Chaque lot contient un nombre limité d’enregistrements
     *     (par défaut 200, mais personnalisable lors de l’appel du batch).
     *
     * @param bc     Contexte du batch.
     * @param scope  Liste des comptes à traiter dans ce lot.
     */
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        // Initialisation d’un Set pour stocker les Ids des comptes
        Set<Id> accountIds = new Set<Id>();

        // Parcours de la liste pour récupérer les Ids
        for (Account acc : scope) {
            accountIds.add(acc.Id);
        }

        // Appel logique existante (réutilisation du code déjà testé)
        // Cette méthode met à jour le champ AnnualRevenue
        // en fonction de la somme des commandes associées (Commande__c).
        UpdateAccountCAHandler.recalcRevenueForAccounts(accountIds);
    }

    /**
     * Méthode FINISH
     * ------------------------------------------------------------
     * Objectif :
     *   - Exécutée une seule fois à la fin du batch.
     *   - Peut servir à :
     *        • Envoyer une notification,
     *        • Enregistrer un log d’exécution,
     *        • Lancer un autre processus en chaîne.
     *
     * @param bc Contexte du batch.
     */
    public void finish(Database.BatchableContext bc) {
        // Simple message de confirmation dans les logs
        System.debug('Batch terminé avec succès pour la mise à jour des comptes.');
    }
}

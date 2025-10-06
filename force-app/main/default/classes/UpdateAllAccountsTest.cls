/**
 * Classe de test unitaire : UpdateAllAccountsTest
 * ------------------------------------------------------------
 * Cette classe vérifie le bon fonctionnement du batch Apex
 * `UpdateAllAccounts`, qui met à jour le chiffre d’affaires
 * (AnnualRevenue) de chaque compte à partir de la somme des montants
 * des commandes (Commande__c) associées.
 *
 *  Objectif :
 *    - S’assurer que le batch traite correctement les enregistrements.
 *    - Valider que le champ AnnualRevenue est mis à jour
 *      conformément à la logique métier implémentée dans
 *      la classe UpdateAccountCAHandler.
 *
 * Bonnes pratiques respectées :
 *    - Utilisation de Test.startTest() / Test.stopTest() pour isoler l’exécution.
 *    - Création de données de test locales (aucune dépendance à l’environnement).
 *    - Assertion explicite pour valider le résultat attendu.
 *
 * Auteur  : Hafsa Belkasmi  
 * Date    : Octobre 2025  
 * Version : 1.0
 */
@IsTest
private class UpdateAllAccountsTest {

    /**
     * Méthode de test principale : testBatchExecution
     * ------------------------------------------------------------
     * Objectif :
     *   - Tester l’exécution complète du batch UpdateAllAccounts.
     *   - Vérifier que la méthode met bien à jour le champ AnnualRevenue
     *     du compte concerné à partir des commandes associées.
     *
     * Étapes du test :
     *  Création d’un compte de test.
     *  Insertion d’une commande associée à ce compte.
     *  Exécution du batch avec Database.executeBatch().
     *   Vérification que le champ AnnualRevenue a bien été mis à jour.
     */
    @IsTest
    static void testBatchExecution() {
        // --- 1️ Préparation des données de test ---
        // Création d’un compte fictif
        Account acc = new Account(Name = 'Batch Test');
        insert acc;

        // Insertion d’une commande associée à ce compte
        insert new Commande__c(
            Compte__c = acc.Id,
            NetAmount__c = 500,
            Statut__c = 'Activated'
        );

        // --- Exécution du batch ---
        // On lance le batch en isolant son exécution dans un contexte de test
        Test.startTest();
        Database.executeBatch(new UpdateAllAccounts(), 200);
        Test.stopTest();

        // ---Vérification du résultat ---
        // On relit le compte pour s’assurer que le champ AnnualRevenue a été mis à jour
        Account refreshed = [SELECT AnnualRevenue FROM Account WHERE Id = :acc.Id];

        // Assertion pour garantir que la valeur a bien été recalculée à 500
        System.assertEquals(
            500,
            refreshed.AnnualRevenue,
            'Le champ AnnualRevenue doit être mis à jour correctement par le batch.'
        );
    }
}

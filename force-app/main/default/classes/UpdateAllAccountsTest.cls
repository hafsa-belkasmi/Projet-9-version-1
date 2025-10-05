/**
 * Classe de test unitaire pour UpdateAllAccounts.
 *
 * Objectif :
 *   Vérifier que la méthode updateAccounts() déclenche bien le recalcul
 *   du chiffre d’affaires (AnnualRevenue) sur les comptes transmis,
 *   en s’appuyant sur la logique du handler UpdateAccountCAHandler.
 *
 * Points de contrôle :
 *   - Vérifier que le champ AnnualRevenue est mis à jour avec la somme correcte.
 *   - S’assurer que la méthode supporte les appels en masse (List<Id>).
 */
@IsTest
private class UpdateAllAccountsTest {

    /**
     * Test principal : valide que le recalcul en masse met à jour correctement
     * le champ AnnualRevenue du compte à partir des commandes associées.
     */
    @IsTest
    static void bulk_update_sets_revenue() {
        // --- Préparation des données ---
        // Création d’un compte de test
        Account acc = new Account(Name = 'Test Account 1');
        insert acc;

        // Insertion de commandes associées à ce compte
        // Total attendu : 80 + 40 = 120
        insert new List<Commande__c>{
            new Commande__c(Compte__c = acc.Id, NetAmount__c = 80, Statut__c = 'Activated'),
            new Commande__c(Compte__c = acc.Id, NetAmount__c = 40, Statut__c = 'Activated')
        };

        // --- Exécution du traitement ---
        // On passe une liste contenant l’Id du compte à la méthode à tester.
        Test.startTest();
        UpdateAllAccounts.updateAccounts(new List<Id>{ acc.Id });
        Test.stopTest();

        // --- Vérification du résultat ---
        // Relecture du compte pour s’assurer que le champ AnnualRevenue a été mis à jour
        Account refreshed = [SELECT AnnualRevenue FROM Account WHERE Id = :acc.Id];

        // Vérifie que le montant correspond bien à la somme des commandes
        System.assertEquals(
            120,
            (Decimal)refreshed.AnnualRevenue,
            'AnnualRevenue doit égaler la somme des NetAmount__c (80 + 40 = 120).'
        );
    }
}

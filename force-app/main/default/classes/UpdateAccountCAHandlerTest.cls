/**
 * Classe de test unitaire pour UpdateAccountCAHandler.
 *
 * Objectif :
 *   Vérifier que la méthode recalcRevenueForAccounts() met correctement à jour
 *   le champ AnnualRevenue des comptes à partir de la somme des montants
 *   NetAmount__c des commandes (Commande__c) associées.
 *
 * Bonnes pratiques :
 *   - Les données de test sont isolées et créées localement.
 *   - L’utilisation de Test.startTest()/Test.stopTest() garantit une exécution propre.
 *   - Chaque assertion décrit clairement l’attendu métier.
 */
@IsTest
private class UpdateAccountCAHandlerTest {

    /**
     * Test principal : valide que le recalcul met bien à jour le champ AnnualRevenue
     * du compte avec la somme totale des NetAmount__c de ses commandes.
     */
    @IsTest
    static void recalc_sets_annual_revenue() {
        // --- Préparation des données ---
        // Création d’un compte de test
        Account acc = new Account(Name = 'Test');
        insert acc;

        // Insertion de deux commandes liées à ce compte
        // Total attendu : 80 + 40 = 120
        insert new List<Commande__c>{
            new Commande__c(Compte__c = acc.Id, NetAmount__c = 80, Statut__c = 'Activated'),
            new Commande__c(Compte__c = acc.Id, NetAmount__c = 40, Statut__c = 'Activated')
        };

        // --- Exécution du traitement testé ---
        Test.startTest();
        UpdateAccountCAHandler.recalcRevenueForAccounts(new Set<Id>{ acc.Id });
        Test.stopTest();

        // --- Vérification du résultat ---
        // On recharge le compte pour lire la valeur mise à jour
        Account refreshed = [SELECT AnnualRevenue FROM Account WHERE Id = :acc.Id];

        // Vérifie que la valeur AnnualRevenue correspond bien à la somme des commandes
        System.assertEquals(
            120, 
            (Decimal)refreshed.AnnualRevenue,
            'AnnualRevenue doit égaler la somme des NetAmount__c (80 + 40 = 120).'
        );
    }
}
  
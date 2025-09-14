public with sharing class MyTeamOrdersController {
    @AuraEnabled(cacheable=true)
    public static Decimal getSumOrdersByAccount(Id accountId) {
        // Agrégation côté SOQL (beaucoup plus rapide et scalable)
        AggregateResult[] ar = [
            SELECT SUM(NetAmount__c) total
            FROM Commande__c
            WHERE Compte__c = :accountId
              AND Statut__c = 'Activated'   // << important pour la sélectivité et la cohérence métier
        ];
        if (!ar.isEmpty() && ar[0].get('total') != null) {
            return (Decimal) ar[0].get('total');
        }
        return 0;
    }
}

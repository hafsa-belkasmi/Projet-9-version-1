public without sharing class MyTeamOrdersController {

    // Somme TOTALE de toutes les Commande__c du compte (tous statuts)
    @AuraEnabled(cacheable=true)
    public static Decimal getSumOrdersByAccount(Id accountId) {
        if (accountId == null) return 0;
        AggregateResult[] ar = [
            SELECT SUM(NetAmount__c) total
            FROM Commande__c
            WHERE Compte__c = :accountId
        ];
        return (ar.size() > 0 && ar[0].get('total') != null) ? (Decimal) ar[0].get('total') : 0;
    }

    // Somme des Commande__c "activées" (champ : Statut__c)
    @AuraEnabled(cacheable=true)
    public static Decimal getSumActivatedOrdersByAccount(Id accountId) {
        if (accountId == null) return 0;
        AggregateResult[] ar = [
            SELECT SUM(NetAmount__c) total
            FROM Commande__c
            WHERE Compte__c = :accountId
              AND Statut__c = 'Activated'
        ];
        return (ar.size() > 0 && ar[0].get('total') != null) ? (Decimal) ar[0].get('total') : 0;
    }
}

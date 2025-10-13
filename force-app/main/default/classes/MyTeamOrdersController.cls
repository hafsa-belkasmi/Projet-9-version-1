/**
 * Classe Apex exposée aux composants Lightning (Aura / LWC).
 * Objectif : récupérer les montants totaux des commandes associées à un compte.
 *
 * Note :
 *  - Le champ NetAmount__c est calculé par le trigger selon la formule :
 *      NetAmount__c = TotalAmount__c - ShipmentCost__c
 *  - Ici, on ne refait pas le calcul : on agrège simplement NetAmount__c.
 */
public without sharing class MyTeamOrdersController {

    /**
     * Récupère la somme TOTALE des montants nets (NetAmount__c)
     * de toutes les commandes (Commande__c) liées à un compte donné,
     * sans filtrer par statut.
     *
     * @param accountId Id du compte cible
     * @return Somme des montants nets (0 si aucune commande trouvée ou si l'Id est nul)
     */
    @AuraEnabled(cacheable=true)
    public static Decimal getSumOrdersByAccount(Id accountId) {
        if (accountId == null) return 0;

        // Agrégation des NetAmount__c liés au compte
        AggregateResult[] ar = [
            SELECT SUM(NetAmount__c) total
            FROM Commande__c
            WHERE Compte__c = :accountId
        ];

        // Retourne la somme si disponible, sinon 0
        return (ar.size() > 0 && ar[0].get('total') != null)
            ? (Decimal) ar[0].get('total')
            : 0;
    }

    /**
     * Récupère la somme des montants nets (NetAmount__c)
     * des commandes liées à un compte dont le statut est "Activated".
     *
     * @param accountId Id du compte cible
     * @return Somme des montants nets des commandes activées (0 si aucune commande ou Id nul)
     */
    @AuraEnabled(cacheable=true)
    public static Decimal getSumActivatedOrdersByAccount(Id accountId) {
        if (accountId == null) return 0;

        // Agrégation filtrée uniquement sur les commandes activées
        AggregateResult[] ar = [
            SELECT SUM(NetAmount__c) total
            FROM Commande__c
            WHERE Compte__c = :accountId
              AND Statut__c = 'Activated'
        ];

        // Retourne la somme si disponible, sinon 0
        return (ar.size() > 0 && ar[0].get('total') != null)
            ? (Decimal) ar[0].get('total')
            : 0;
    }
}

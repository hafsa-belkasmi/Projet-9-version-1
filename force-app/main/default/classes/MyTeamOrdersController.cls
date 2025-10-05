/**
 * Classe Apex exposée aux composants Lightning (Aura / LWC) 
 * permettant de récupérer les montants totaux des commandes associées à un compte.
 * 
 * Note :
 *  - "without sharing" : la classe exécute le code sans appliquer les règles de partage,
 *    ce qui peut être intentionnel pour permettre une vision complète des données.
 *  - Méthodes @AuraEnabled(cacheable=true) : optimisées pour la consultation depuis le client
 *    avec mise en cache côté navigateur.
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
        // Vérification défensive : si aucun Id fourni, renvoie 0
        if (accountId == null) return 0;
        
        // Requête d’agrégation pour sommer tous les NetAmount__c liés au compte
        AggregateResult[] ar = [
            SELECT SUM(NetAmount__c) total
            FROM Commande__c
            WHERE Compte__c = :accountId
        ];
        
        // Si un résultat est trouvé et non nul, on retourne la somme ; sinon 0
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
        // Vérification défensive : si aucun Id fourni, renvoie 0
        if (accountId == null) return 0;
        
        // Requête d’agrégation filtrée uniquement sur les commandes activées
        AggregateResult[] ar = [
            SELECT SUM(NetAmount__c) total
            FROM Commande__c
            WHERE Compte__c = :accountId
              AND Statut__c = 'Activated'
        ];
        
        // Renvoie la somme si disponible, sinon 0
        return (ar.size() > 0 && ar[0].get('total') != null) 
            ? (Decimal) ar[0].get('total') 
            : 0;
    }
}

/**
 * ==============================================================
 * Trigger : CalculMontantCommande
 * ==============================================================
 * Objectif :
 *   - Calculer automatiquement le champ NetAmount__c
 *     d’une commande (Commande__c) avant insertion ou mise à jour.
 * 
 * Détails :
 *   - Le NetAmount__c correspond à la somme de :
 *       → TotalAmount__c (montant de la commande)
 *       → ShipmentCost__c (frais d’expédition)
 *   - Le calcul est effectué uniquement lorsque :
 *       • L’un des deux champs est renseigné (TotalAmount__c / ShipmentCost__c)
 *         → évite les mises à jour inutiles.
 *       • OU lorsque NetAmount__c est encore vide.
 * 
 * Événements :
 *   - before insert, before update
 *     → permet d’écrire la valeur NetAmount__c avant l’enregistrement en base.
 * 
 * Bonnes pratiques :
 *   - Pas de requêtes ni DML dans le trigger → respect des limites Salesforce.
 *   - Logique simple, claire et testée par CalculMontantTriggerTest.
 * ==============================================================
 */

trigger CalculMontantCommande on Commande__c (before insert, before update) {
    
    // Parcourt tous les enregistrements concernés par l’opération DML
    for (Commande__c c : Trigger.new) {
        
        // Vérifie si l’un des champs d’entrée (TotalAmount__c, ShipmentCost__c)
        // est renseigné OU si le NetAmount__c est encore vide (à initialiser)
        Boolean hasInputs = (c.TotalAmount__c != null) || (c.ShipmentCost__c != null);

        if (hasInputs || c.NetAmount__c == null) {
            // Valeurs par défaut à 0 pour éviter les NullPointerException
            Decimal total = (c.TotalAmount__c == null) ? 0 : c.TotalAmount__c;
            Decimal ship  = (c.ShipmentCost__c == null) ? 0 : c.ShipmentCost__c;

            // Calcul du montant net : somme du total et des frais de livraison
            c.NetAmount__c = total + ship;
        }
    }
}

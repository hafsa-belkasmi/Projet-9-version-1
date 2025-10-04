trigger CalculMontantCommande on Commande__c (before insert, before update) {
    for (Commande__c c : Trigger.new) {
        // Recalcule uniquement si on a des éléments pour le faire
        // (au moins un des deux montants est présent) OU si Net est vide.
        Boolean hasInputs = (c.TotalAmount__c != null) || (c.ShipmentCost__c != null);
        if (hasInputs || c.NetAmount__c == null) {
            Decimal total = (c.TotalAmount__c == null) ? 0 : c.TotalAmount__c;
            Decimal ship  = (c.ShipmentCost__c == null) ? 0 : c.ShipmentCost__c;
            c.NetAmount__c = total + ship;
        }
    }
}

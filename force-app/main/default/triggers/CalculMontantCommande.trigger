trigger CalculMontantCommande on Commande__c (before insert, before update) {
    for (Commande__c c : Trigger.new) {
        Decimal total = (c.TotalAmount__c  == null) ? 0 : c.TotalAmount__c;
        Decimal ship  = (c.ShipmentCost__c == null) ? 0 : c.ShipmentCost__c;
        // Net = Total + Frais d'expédition (attendu par l'étape)
        c.NetAmount__c = total + ship;
    }
}

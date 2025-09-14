public with sharing class UpdateAllAccounts {

    /**
     * Utilitaire pour recalculer via une List<Id> (appel depuis tests/LWC/etc.).
     */
    public static void updateAccounts(List<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) return;
        UpdateAccountCAHandler.recalcRevenueForAccounts(new Set<Id>(accountIds));
    }
}

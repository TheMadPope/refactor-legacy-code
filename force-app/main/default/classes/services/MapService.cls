public without sharing abstract class MapService {

    /**
     * Example of the kind of method you might want to make to save you time in the future!
     * Keep building a map of xByY? Make it a reusable method!
     */
    public static Map<String, Account> buildAccountByName(List<Account> records) {
        Map<String, Account> accountByName = new Map<String, Account>();
        for (Account record : records) {
            accountByName.put(record.Name, record);
        }
        return accountByName;
    }
}
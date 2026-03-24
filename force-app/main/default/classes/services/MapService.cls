public without sharing abstract class MapService {

    public static Map<String, Account> buildAccountByName(List<Account> records) {
        Map<String, Account> accountByName = new Map<String, Account>();
        for (Account record : records) {
            accountByName.put(record.Name, record);
        }
        return accountByName;
    }
}
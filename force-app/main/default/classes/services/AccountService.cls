public inherited sharing abstract class AccountService {

    /**
     * Simple example of a reusable method to do a thing repeatedly.
     * In this case the source is passed in. But if you're always doing the SAME source, you might leave off
     * the variable and just hardcode the value in the method.
     * It's generally safe to assume that if you're segregating records by X criteria once,
     * and that segregation is important for your org, you're going to do it again.
     */
    public static List<Account> getAccountsWithSource(String source, List<Account> records){
        List<Account> matches = new List<Account>();
        for (Account record : records){
            if (record.AccountSource != source){
                continue;
            }
            matches.add(record);
        }
        return matches;
    }
}
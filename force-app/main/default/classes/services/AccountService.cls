public inherited sharing abstract class AccountService {

    /**
     * Simple example of a reusable method to do a thing repeatedly.
     * In this case the source is passed in. But if you're always doing the SAME source, you might leave off
     * the variable and just hardcode the value in the method.
     * It's generally safe to assume that if you're segregating records by X criteria once,
     * and that segregation is important for your org, you're going to do it again.
     * Now, AccountSource is a bad example for that - passing in the value is likely the right choice.
     * But if you have deeper/more complex criteria, you might want that logic inside this method.
     * OR IN ANOTHER METHOD.
     * The key here will be to iterate to find the common, reusable methods that you can introduce and use later,
     * saving yourself time.
     * Notice that here we're not QUERYing the records, we're parsing an inbound list.
     * If it was a query, it would live in the Selector.
     * Since it's doing things to Accounts, it lives in the AccountService.
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
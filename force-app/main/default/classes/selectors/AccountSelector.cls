public inherited sharing class AccountSelector {

    /**
     * Notice there's not a crazy overloading framework here. A Selector can be just a place for queries to live.
     * This mainly increases readability, and, say, to include a new important field in the query
     * anywhere it's invoked.
     * When I'm refactoring I will do a FIND for every query I come across to see if it's repeated.
     * Those are the best targets for moving into a Selector.
     * Personally, I like to have nearly all queries in a selector.
     */
    public List<Account> getAccountsBySource(String source){
        return [SELECT Id, Name
                FROM Account\
                WHERE AccountSource = :source];
    }

    public static void whenNotToUseASelector(){
        //First off, here's what you WOULD use a selector.
        /*START*/
        //do things
        List<Account> accountsWithAdvertisementSource = [SELECT Id, Name
                                                         FROM Account
                                                         WHERE AccountSource = 'Advertisement'];
        //do other things
        /*END*/
        //Pretty straightforward.

        //Here's where you should NOT use a selector.
        /*START*/
        for (Account record :[SELECT Id, Name
                              FROM Account
                              WHERE AccountSource = 'Advertisement']){
            //do things
        }
        /*END*/
        /*When the query is the variable_list part of the for statement, Apex will chunk that out into
        * batches of 200 records automatically. If you put the query in a selector, it will NOT do that.
        * This is especially true if there's even a risk of hitting your 50K record limit.
        * Now, if you KNOW that there's a limited set, like [SELECT Name FROM BaskinRobbinsFlavors__c], then it's
        * probably safe to move into a Selector method.
        */
    }

    public static void queryFormattingExample(){
        List<Account> records = [SELECT Id, Name
                                 FROM Account
                                 WHERE AccountSource = 'Advertisement'
                                 AND (Name='Example' OR Name='Test')];
        /* Now, that's maybe not the BEST example, because who would do that query?
         * But the multiline formatting helps with readability.
         * If the SELECT clause has too many fields, then I will continue that to a new line as well.
         * Always with ID first, then alphabetically, like: SELECT Id, Apple__c, Banana__c...
         *
         * NOTE! Don't be a jerk about it. Do what works for you and your team!
         * I've also seen the below as a preference, and SURE YOU DO YOU!
         */

        List<Account> records2 = [
            SELECT Id, Name
            FROM Account
            WHERE AccountSource = 'Advertisement'
            AND (Name='Example' OR Name='Test')
        ];

    }
}
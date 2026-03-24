public without sharing class RefactorExamples {

    public static void doThingsInALoop_before(List<Account> accs){
        //do some things
        //do some other things
        List<Account> accUps = new List<Account>();
        for(Account r :accs){
            if (r.AccountSource=='Advertisement'){
                //do things
                //update values and whatnot
                accUps.add(r);
            }
        }
        Database.update(accUps);
    }

    /**
     * 1) Renamed variables
     * 2) Moved the filtering action into a reusable service method.
     * TODO: It's entirely possible that the "do some things" and "do some other things"should also be their own methods!
     */
    public static void doThingsInALoop_after(List<Account> records){
        //do some things
        //do some other things
        List<Account> recordsToUpdate = AccountService.getAccountsWithSource('Advertisement', records);
        Database.update(recordsToUpdate);
    }


    public static void doThingsWithRecordTypes_before(){
        RecordTypeInfo myRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('My_Record_Type');
        Id myRecordTypeId = myRecordType.getRecordTypeId();
        for (Account record :records){
            if (record.RecordTypeId == myRecordTypeId){
                //do things
            }
        }
    }

    /**
     * Using that reusable and incredibly performant RecordTypeService
     * Moved the action taken on the Account - let's pretend it was setting a bunch of default values -
     * into a Service method. Maybe it would be called "setDefaultValuesForMyRecordType"
     * Notice that I left this IF statement NOT inverted, I'm going to talk about that next!
     */
    public static void doThingsWithRecordTypes_after(List<Account> records){
        Id myRecordTypeId = RecordTypeService.getRecordTypeId('Account', 'My_Record_Type');
        for (Account record :records){
            if (record.RecordTypeId == myRecordTypeId){
                FakeService.doSingleRecord(record);
            }
            //Arguably, this for Loop itself might make sense in its own method.
        }
    }

    /**
     * In this example we have multiple clauses in our IF statement.
     * This should be inverted to be more clear, reduce nesting, reduce cyclomatic complexity.
     * This is especially true the MORE clauses you have
     */
    public static void invertIfStatements_before(List<Account> records){
        for (account record :records){
            if (record.AccountSource == 'Advertisement' && record.Type=='Competitor'){
                //do some things
            }
        }
    }

    /**
     * The IFs have been inverted. This makes it way more clear what is going on.
     * It also makes it incredibly easy to test each logical branch
     */
    public static void invertIfStatements_after(List<Account> records){
        for (account record :records){
            if (record.AccountSource != 'Advertisement'){
                continue;
            }
            if (record.Type != 'Competitor'){
                continue;
            }
            //do some things
        }
    }

    /**
     * If you're, say, making a map that is meaningful in your org, it's likely you're going to need the
     * same map in the future. If you're writing code, you're doing it wrong!
     */
    public static void methodThatDoesCommonThingsLikeMakeAMap_before(List<Account> records){
        //do things
        Map<String, Account> accountByName = new Map<String, Account>();
        for (Account record :records){
            accountByName.put(record.Name, record);
        }
        //do other things
    }

    /**
     * This is very clear, gives you reusable functionality, and... it's just GOOD
     */
    public static void methodThatDoesCommonThingsLikeMakeAMap_after(List<Account> records){
        //do things
        Map<String, Account> accountByName = MapService.buildAccountByName(records);
        //do other things
    }

    /**
     * Here's an example of a thing you might be doing a lot. If you do, break it out!
     * This would probably live in a SetService or a StringService.
     * The purpose here is not performance, just reusability.
     * It also makes the calling code more like natural language, and it's incredibly easy to test.
     * If in the future, a new Apex feature allows a construction like "new Set<String>{listOfLists}",
     * just update this single method and all your code benefits!
     */
    public static Set<String> addAllStringsFromLists(List<List<String>> listOfLists){
        Set<String> result = new Set<String>();
        for (List<String> thisList :listOfLists){
            result.addAll(thisList);
        }
        return result;
}
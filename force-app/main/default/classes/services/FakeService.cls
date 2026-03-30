public inherited sharing abstract class FakeService {

    //Added this so that you could deploy the other example methods if you really wanted to.
    public static void doSingleRecord(SObject record){
        //do things
    }

    //Invoked by the ExampleAccountTriggerHandler - note the implicit cast from List<sObject> to List<Account>!
    public static void takeAListOfAccounts(List<Account> newRecords){
    }

    //Invoked by the ExampleAccountTriggerHandler - the caller must explicitly cast to change from sObject
    public static void takeAMapOfAccounts(Map<Id, Account> newRecords){
    }
}
/**
 * Example of an TriggerHandler extending the virtual TriggerHandler class. Should be invoked within a Trigger - just instantiate and run (for all contexts)
 */
public class ExampleAccountTriggerHandler extends TriggerHandler {

    /**
     * Action(s) to take on the Before Insert operation.
     * NOTE! If you're not actually doing anything on this (or any) stage, DO NOT implement this method, just delete it!
     * Only override those methods where you want to actually take action
     * Should invoke a Service class to do actual work, keep any logic out of the Handler
     * @param newRecords (List<SObject>): Records that will be inserted, from the Context.
     */
    public override void beforeInsert(List<sObject> newRecords) {
        //Note that the override signature is sObject, but the target method here takes List<Account>, as implicit conversion is our friend
        FakeService.takeAListOfAccounts(newRecords);
    }

    /**
     * Action(s) to take on After Insert action.
     * @param newRecords (Map<Id, SObject>): Map of records after insert, by their Ids
     */
    public override void afterInsert(Map<Id, SObject> newRecords) {
        //If I was using reference data in multiple methods, I would put it into a local variable.
        //Obviously I would use the appropriate Service or Selector to get the data.
        //For this example, I just wanted to catch your eye. This will help us avoid repeated queries in the trigger execution context.
        List<Campaign> referenceRecords = new List<Campaign>();

        //No need to cast when passing a list
        FakeService.takeAListOfAccounts(newRecords.values());

        //Note the cast to Map<Id, Account> - When passing the map you have to cast to the specified type
        //If I was doing this in more places I would intantiate a local variable.
        FakeService.takeAMapOfAccounts((Map<Id, Account>)newRecords);
    }

    /**
     * Action(s) to take on Before Update action.
     * NOTE! This is an example of a trigger bypass in action.
     * @param newRecordsById (Map<Id, SObject>): Map of records after insert, by their Ids
     * @param oldRecordsById (Map<Id, SObject>): Map of records after insert, by their Ids
     */
    public override void beforeUpdate(Map<Id, SObject> newRecordsById, Map<Id, SObject> oldRecordsById){
       //I have it as a single line conditional, which I typically avoid, but this way
       //You don't have to do dependency injection, and you get to 100% test coverage.
        if (TriggerService.isBypassEnabled('ExampleAccountTriggerHandler.beforeUpdate')){ return; }
    }
}
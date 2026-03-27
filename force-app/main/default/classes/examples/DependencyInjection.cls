public without sharing abstract class DependencyInjection {

    /*
     * A common thing I see in triggers is a few different kinds of logic, like this example:
     *
     * if (!TriggerSetting.isFeatureDisabled('MyTriggerAction')){
     *    doTheThing(newRecords);
     * }
     *
     * if (TriggerConfiguration.isEnabled('MyOtherTriggerAction')){
     *     doTheOtherThing(newRecords);
     * }
     *
     * We should normalize that (if only for sanity, but also for testability))
     * Check out how easy these methods are to test NOW!
     * New code:
     *
     * doTheThing(newRecords, !TriggerSetting.isFeatureDisabled('MyTriggerAction'));
     * doTheOtherThing(newRecords, TriggerConfiguration.isEnabled('MyOtherTriggerAction'));
     */

    public static void doTheThing(List<SObject> newRecords, Boolean isActionEnabled){
        if (!isActionEnabled){
             return;
        }
        //do the thing
    }

    public static void doTheOtherThing(List<SObject> newRecords, Boolean isActionEnabled){
        if (!isActionEnabled){
            return;
        }
        //do the other thing
    }

    /**
     * But what if the target method is being used elsewhere, without the switch?
     * In that case, introduce a private method. So:
     * keep:
     * public static void doTheThing(List<SObject> newRecords)...
     * This just does the thing.
     *
     * add:
     * public static void doTheThingIfEnabled(List<SObject> newRecords, Boolean isActionEnabled)...
     * This checks the setting and (if enabled) calls doTheThing
     */

     /*
      * Another common issue that I see is invoking Custom Metadata inside a method.
      * I mean, that's fine, go ahead and do that! But allow us to pass in the value for testing.
      */
    public static void notRefactoredMethod(List<SObject> newRecords){
        SystemSetting__mdt setting = [SELECT Id, DeveloperName, Value__c
                                      FROM SystemSetting__mdt
                                      WHERE Name = 'MySetting'
                                      LIMIT 1];
        if (setting.Value__c == 'valueA'){
            //do some things
        } else if (setting.Value__c == 'valueB'){
            //do some other things
        } else {
            //do the default things
        }
        //This is hard if not impossible to test because it relies on REAL Custom Metadata
        //Even worse, you often see: if (Test.isRunningTest())... which I see as a red flag for refactoring.
    }

    //OK, so notice that we just go directly to the private method. This way the public signature remains
    //secure, no one is going to pass in a SystemSetting__mdt record in production code, but we can in tests!
    public static void refactoredMethod(List<SObject> newRecords){
        refactoredMethod(newRecords, null);
    }

    @TestVisible
    private static void refactoredMethod(List<SObject> newRecords, SystemSetting__mdt setting){
        if (setting == null){
            //In reality I'd be getting this from a Service method
            setting = [SELECT Id, DeveloperName, Value__c
                       FROM SystemSetting__mdt
                       WHERE Name = 'MySetting'
                       LIMIT 1];
        }
        if (setting.Value__c == 'valueA'){
            //do some things
        } else if (setting.Value__c == 'valueB'){
            //do some other things
        } else {
            //do the default things
        }
        //Now we can EASILY test this method by passing in a SystemSetting__mdt that we built using our TestFactory method
        //You can also test each logical branch easily
        //Of course, depending on what is happening in each logical branch, those will possibly be their own methods.
        //Just wanted to show passing in the Custom Metadata as a parameter for testability!
    }
}
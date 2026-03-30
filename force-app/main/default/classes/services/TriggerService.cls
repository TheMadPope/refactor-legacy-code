public without sharing abstract class TriggerService {

    /**
     * This class is in service of the ExampleAccountTriggerHandler.
     * Its purpose is to demonstrate how a Trigger action bypass might be implemented.
     * Arguably, this could live in the SystemSettingService, much like 'isFeatureOn'.
     * I think I like wrapping it in the TriggerService because when I'm in the TriggerHandler
     * wondering if the Trigger Action should be bypassed, my gut reaction was 'Better check the TriggerService'
     */
    public static Boolean isBypassEnabled(String triggerActionName){
        SystemSetting__mdt record = SystemSettingService.getByCategoryAndKey(SystemSettingService.CATEGORY_TRIGGER_ACTION_DISABLE, triggerActionName);
        return record==null ? false : record.Value__c.toLowerCase().trim() == 'true';
    }
}
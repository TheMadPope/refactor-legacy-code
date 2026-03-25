/*
* @description: Service for getting values from the SystemSetting__mdt Custom Metadata Type
*/
public without sharing abstract class SystemSettingService{

    /*
     * @description: Static values for Category__c picklist
     */
    public static final String CATEGORY_FEATURE_ACTIVATION = 'Feature Activation';
    public static final String CATEGORY_FEATURE_VERSION = 'Feature Version';
    public static final String CATEGORY_TRIGGER_ACTION_DISABLE = 'Trigger Action Disable';

    /*
     * @description: If the Setting is set to a Key__c of Feature Name and a Value__c of 'true', return true. Otherwise, false.
     * Public method, inner method allows dependency injection.
     * @param featureName (String): The name of the feature that we are checking. Is this enabled?
     * @returns Boolean: true if enabled, otherwise false.
     */
    @AuraEnabled
    public static boolean isFeatureOn(string featureName){
        return isFeatureOn(featureName, null);
    }

    /*
     * @description: If the Setting is set to a Key__c of Feature Name and a Value__c of 'true', return true. Otherwise, false.
     * Private method, TestVisible, to allow dependency injection.
     * @param featureName (String): The name of the feature that we are checking. Is this enabled?
     * @param setting (SystemSetting__mdt): Record deliberately passed in via unit test
     * @returns Boolean: true if enabled, otherwise false.
     */
    @TestVisible
    private static boolean isFeatureOn(string featureName, SystemSetting__mdt setting){
        if (setting==null){
            setting = getByCategoryAndKey(CATEGORY_FEATURE_ACTIVATION, featureName);
        }
        if(setting==null){
            return false;
        }
        if (setting.Value__c != 'true'){
            return false;
        }
        return true;
    }

    /*
     * @description: Get the Value__c of the feature version.
     * Private method, TestVisible, to allow dependency injection.
     * @param featureName (String): The name of the feature that we are checking.
     * @param setting (SystemSetting__mdt): Record deliberately passed in via unit test
     * @returns String: The feature version if available, otherwise null.
     */
    @TestVisible
    private static String getFeatureVersion(string featureName, SystemSetting__mdt setting){
        if (setting==null){
            setting = getByCategoryAndKey(CATEGORY_FEATURE_VERSION, featureName);
        }
        if(setting==null){
            return null;
        }
        return setting.Value__c;
    }

    /**
     * @description: Get the SystemSetting__mdt record by category and key.
     * @param category (String): The category of the setting.
     * @param key (String): The key of the setting.
     * @returns SystemSetting__mdt: The setting record if available, otherwise null.
     */
    public static SystemSetting__mdt getByCategoryAndKey(String category, String key) {
        return getByCategoryAndKey(category, key, null);
    }

    /**
     * @description: Get the SystemSetting__mdt record by category and key.
     * Private method, TestVisible, to allow dependency injection.
     * @param category (String): The category of the setting.
     * @param key (String): The key of the setting.
     * @param settings (List<SystemSetting__mdt>): Records deliberately passed in via unit test
     * @returns SystemSetting__mdt: The setting record if available, otherwise null.
     */
    @TestVisible
    private static SystemSetting__mdt getByCategoryAndKey(String category, String key, List<SystemSetting__mdt> settings) {
        if (settings==null){
            settings = [SELECT Id, DeveloperName, MasterLabel, Key__c, Value__c, Category__c
                        FROM SystemSetting__mdt
                        WHERE Category__c =:category
                        AND Key__c =:key
                        LIMIT 1];
        }
        if(settings.isEmpty()){
            return null;
        }
        return settings[0];
    }

    /**
     * @description: Get a map with the Key__c as the key and Value__c as the value for all
     *               SystemSetting__mdt records in a specified category.
     * @param category (String): The category of the settings.
     * @returns Map<String, String>: A map with the Key__c as the key and Value__c as the value for all
     *                               SystemSetting__mdt records in the specified category.
     */
    public static Map<String, String> getValuesByKey(String category) {
        return getValuesByKey(category, null);
    }

    /**
     * @description: Get a map with the Key__c as the key and Value__c as the value for all
     *               SystemSetting__mdt records in a specified category.
     * Private method, TestVisible, to allow dependency injection.
     * @param category (String): The category of the settings.
     * @param settings (List<SystemSetting__mdt>): Records deliberately passed in via unit test
     * @returns Map<String, String>: A map with the Key__c as the key and Value__c as the value for all
     *                               SystemSetting__mdt records in the specified category.
     */
    @TestVisible
    private static Map<String, String> getValuesByKey(String category, List<SystemSetting__mdt> settings) {
        if (settings == null) {
            settings = getByCategory(category, null);
        }
        Map<String, String> values = new Map<String, String>();
        for (SystemSetting__mdt setting : settings) {
            values.put(setting.Key__c, setting.Value__c);
        }
        return values;
    }

    /**
     * @description: Get a list of SystemSetting__mdt records for a specified category.
     * @param category (String): The category of the settings.
     * @returns List<SystemSetting__mdt>: A list of SystemSetting__mdt records for the specified category.
     */
    public static List<SystemSetting__mdt> getByCategory(String category) {
        return getByCategory(category, null);
    }


    /**
     * @description: Get a list of SystemSetting__mdt records for a specified category.
     * Private method, TestVisible, to allow dependency injection.
     * @param category (String): The category of the settings.
     * @param settings (List<SystemSetting__mdt>): Records deliberately passed in via unit test
     * @returns List<SystemSetting__mdt>: A list of SystemSetting__mdt records for the specified category.
     */
    @TestVisible
    private static List<SystemSetting__mdt> getByCategory(String category, List<SystemSetting__mdt> settings) {
        if (settings==null){
            settings = [SELECT Id, DeveloperName, MasterLabel, Key__c, Value__c, Category__c
                        FROM SystemSetting__mdt
                        WHERE Category__c =:category
                        LIMIT 1];
        }
        if(settings.isEmpty()){
            return null;
        }
        return settings;
    }
}

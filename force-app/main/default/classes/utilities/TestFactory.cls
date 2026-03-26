
@IsTest
public class TestFactory{

    //REGION A

    /**
     * Builds an sObject using the parameters provided (or defaults); Optionally inserts the record
     * @param parameters (Map<String, object>): Fields to set on the object
     * @param doInsert (boolean): If TRUE, performs Database.insert
     * @return Account: Created sObject
     * @notes: Check out this example method! You could build a method like this for any sObject type
     *         that you use in your tests, and use them throughout!
     *         Also note the option to NOT insert the record. In tests, we want to avoid the database
     *         wherever possible, to focus on testing BEHAVIOR.
     *         There's a place for integration tests that DO hit the database, to be sure.
     *         But you want to keep those separate and be deliberate about WHICH kind of test you're writing.
     */
    public static Account accountBuild(Map<String, object> parameters, boolean doInsert){
        if (parameters == null){
            parameters = new Map<String, object>();
        }
        //Add required fields with defaults if not provided in the parameters
        if (!parameters.containsKey('Name')){
            parameters.put('Name', 'TestAccount' + randomString(10));
        }
        Account result = (Account) JSON.deserialize(JSON.serialize(parameters), Type.forName('Account'));
        if (doInsert){
            Database.insert (result);
        }
        return result;
    }

    //END REGION A

    //REGION C

    /**
     * OVERLOAD: Builds an sObject using the defaults; Optionally inserts the record
     * @param doInsert (boolean): If TRUE, performs Database.insert
     * @return Contact: Created sObject
     * @notes: This is an example of overloading a TestFactory method. For common or simple objects,
     *         you might want a very simple record.
     */
    public static Contact contactBuild(boolean doInsert){
        return contactBuild(null, doInsert);
    }

    /**
     * Builds an sObject using the parameters provided (or defaults); Optionally inserts the record
     * @param parameters (Map<String, object>): Fields to set on the object
     * @param doInsert (boolean): If TRUE, performs Database.insert
     * @return Contact: Created sObject
     */
    public static Contact contactBuild(Map<String, object> parameters, boolean doInsert){
        if (parameters == null){
            parameters = new Map<String, object>();
        }
        if (!parameters.containsKey('FirstName')){
            parameters.put('FirstName', 'FIRST' + randomString(10));
        }
        if (!parameters.containsKey('LastName')){
            parameters.put('LastName', 'LAST' + randomString(10));
        }
        //Not a required field, but I wanted to show another example of using randomString
        if (!parameters.containsKey('Email')){
            parameters.put('Email', randomString(10) + '@example.com');
        }
        Contact result = (Contact) JSON.deserialize(JSON.serialize(parameters), Type.forName('Contact'));
        if (doInsert){
            Database.insert (result);
        }
        return result;
    }

    //END REGION C

    //REGION G

    /**
     * Generates a fake Id that is valid for the given object
     * @param objectType (Schema.SObjectType): The object type to use
     * @return String: The fake Id
     */
    public static String getFakeId(Schema.SObjectType objectType){
        String result = String.valueOf(randomSeed++);
        return objectType.getDescribe().getKeyPrefix() + '0'.repeat(12-result.length()) + result;
    }

    //END REGION G

    //REGION R

    /**
     * Used by random methods to ensure uniqueness
     */
    static integer randomSeed = 1;

    /**
     * Returns a random string of the specified length
     * @param length (integer): The length of string to generate
     * @return String: Random string
     */
    public static String randomString(integer length){
        String stagingKey = String.valueOf(randomSeed++);
        while (stagingKey.length() < length){
            stagingKey += EncodingUtil.base64encode(crypto.generateAesKey(192));
        }
        return stagingKey.substring(0, length).toLowerCase();
    }

    //END REGION R

    //REGION S

    /**
     * Builds a Custom Metadata record using the parameters provided (or defaults); Optionally inserts the record
     * @param parameters (Map<String, object>): Fields to set on the object
     * @param doInsert (boolean): If TRUE, performs Database.insert
     * @return SystemSetting__mdt: Created sObject
     * @notes: Oooh look at that, you can create a Custom Metadat record for use in your testing!
     *         PLEASE NOTE however that you CANNOT insert Custom Metadata. But this works great for dependency injection
     */
    public static SystemSetting__mdt systemSettingBuild(Map<String, object> parameters){
        if (parameters == null){
            parameters = new Map<String, object>();
        }
        //Add required fields with defaults if not provided in the parameters
        if (!parameters.containsKey('Name')){
            parameters.put('Name', 'TestSystemSetting' + randomString(10));
        }
        SystemSetting__mdt result = (SystemSetting__mdt) JSON.deserialize(JSON.serialize(parameters), Type.forName('SystemSetting__mdt'));
        return result;
    }

    //END REGION S
}
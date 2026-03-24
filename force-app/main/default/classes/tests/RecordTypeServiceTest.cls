@IsTest()
public class RecordTypeServiceTest{

    private static final String VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG = 'Account';

    private static String VALID_RECORDTYPE_IN_THIS_ORG { get {
        // Choose the first active RecordType for VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG in this org
        String result = null;
        List<Schema.RecordTypeInfo> infos = Schema.getGlobalDescribe().get(VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG).getDescribe().getRecordTypeInfosByDeveloperName().values();
        for (Schema.RecordTypeInfo info :infos) {
            if (info.isActive()) {
                result = info.getDeveloperName();
                break;
            }
        }
        return result;
    } set;}

    @IsTest
    private static void itShouldgetRecordTypeList(){
        Test.startTest();
        List<RecordType> recordtypeList = RecordTypeService.getRecordTypeList(VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG);
        Test.stopTest();

        Map<String, RecordTypeInfo> control = Schema.getGlobalDescribe().get(VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG).getDescribe().getRecordTypeInfosByDeveloperName();
        integer activeCount=0;
        for (RecordTypeInfo info :control.values()){
            if (info.isActive()){
                activeCount++;
            }
        }

        Assert.areEqual(activeCount, recordtypeList.size(), 'It should have returned the same recordTypes for ' + VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG);
    }

    @IsTest
    private static void itShouldgetRecordTypeIdByDeveloperName(){
        Id control = Schema.getGlobalDescribe().get(VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG).getDescribe().getRecordTypeInfosByDeveloperName().get(VALID_RECORDTYPE_IN_THIS_ORG).getRecordTypeId();

        Test.startTest();
        Map<String, Id> recordtypeIdByDeveloperName = RecordTypeService.getRecordTypeIdByDeveloperName(VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG);
        Test.stopTest();

        Assert.areEqual(recordtypeIdByDeveloperName.get(VALID_RECORDTYPE_IN_THIS_ORG), control, 'It should have returned the appropriate recordTypeId');
    }

    @IsTest
    private static void itShouldgetRecordTypeId(){

        Id control = Schema.getGlobalDescribe().get(VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG).getDescribe().getRecordTypeInfosByDeveloperName().get(VALID_RECORDTYPE_IN_THIS_ORG).getRecordTypeId();

        Test.startTest();
        Id result = RecordTypeService.getRecordTypeId(VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG, VALID_RECORDTYPE_IN_THIS_ORG);
        Test.stopTest();

        Assert.areEqual(result, control, 'It should have returned the requested RecordTypeId');
    }

    @IsTest
    private static void getRecordTypeIdShouldReturnResultFromCache(){
        RecordType fake = new RecordType();
        fake.Id = TestFactory.getFakeId(RecordType.getSObjectType());
        fake.Name = 'fake';
        fake.DeveloperName = 'fake';

        RecordTypeService.cache.put('getRecordTypeAccountfake', fake);

        Test.startTest();
        Id accountRecordTypeId = RecordTypeService.getRecordTypeId(VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG, 'fake');
        Test.stopTest();

        Assert.areEqual(fake.Id, accountRecordTypeId, 'The cached value should have been returned');
    }

    @IsTest
    private static void getRecordTypeShouldReturnResultFromCache(){
        RecordType fake = new RecordType();
        fake.Id = TestFactory.getFakeId(RecordType.getSObjectType());
        fake.Name = 'fake';
        fake.DeveloperName = 'fake';

        RecordTypeService.cache.put('getRecordTypeAccountfake', fake);

        Test.startTest();
        RecordType result = RecordTypeService.getRecordType(VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG, 'fake');
        Test.stopTest();

        Assert.areEqual(fake.Id, result.Id, 'The cached value should have been returned');
    }

    @IsTest
    private static void getRecordTypeListShouldReturnResultFromCache(){
        List<RecordType> fakes = new List<RecordType>();

        RecordType fake = new RecordType();
        fake.Id = TestFactory.getFakeId(RecordType.getSObjectType());
        fake.Name = 'fake';
        fake.DeveloperName = 'fake';
        fakes.add(fake);

        RecordType fake2 = new RecordType();
        fake2.Id = TestFactory.getFakeId(RecordType.getSObjectType());
        fake2.Name = 'fake2';
        fake2.DeveloperName = 'fake2';
        fakes.add(fake2);

        RecordTypeService.cache.put('getRecordTypeList' + VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG, fakes);

        Test.startTest();
        List<RecordType> result = RecordTypeService.getRecordTypeList(VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG);
        Test.stopTest();

        Assert.areEqual(fake.Id, result[0].Id, 'The cached value should have been returned');
        Assert.areEqual(fake2.Id, result[1].Id, 'The cached value should have been returned');
        Assert.areEqual(2, result.size(), 'The cached value (2 records) should have been returned');
    }

    @IsTest
    private static void getRecordTypeIdByDeveloperNameShouldReturnResultFromCache(){
        Map<String, Id> fakes = new Map<String, Id>();

        RecordType fake = new RecordType();
        fake.Id = TestFactory.getFakeId(RecordType.getSObjectType());
        fake.Name = 'fake';
        fake.DeveloperName = 'fake';
        fakes.put(fake.DeveloperName, fake.Id);

        RecordType fake2 = new RecordType();
        fake2.Id = TestFactory.getFakeId(RecordType.getSObjectType());
        fake2.Name = 'fake2';
        fake2.DeveloperName = 'fake2';
        fakes.put(fake2.DeveloperName, fake2.Id);

        RecordTypeService.cache.put('getRecordTypeIdByDeveloperName' + VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG, fakes);

        Test.startTest();
        Map<String, Id> result = RecordTypeService.getRecordTypeIdByDeveloperName(VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG);
        Test.stopTest();

        Assert.areEqual(fake.Id, result.get(fake.DeveloperName), 'The cached value should have been returned');
        Assert.areEqual(fake2.Id, result.get(fake2.DeveloperName), 'The cached value should have been returned');
        Assert.areEqual(2, result.size(), 'The cached value (2 records) should have been returned');
    }

    @IsTest
    private static void getRecordTypeShouldThrowErrorOnInvalidInputs(){
        Boolean errorThrown = false;
        String errorMessage = null;

        Test.startTest();
        try{
            RecordType result = RecordTypeService.getRecordType('fake', 'fake');
        } catch (Exception e){
            errorThrown=true;
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        Assert.areEqual(true, errorThrown, 'An exception should have been thrown');
        Assert.areEqual(errorMessage, 'Unable to find RecordType for object fake with DeveloperName of fake', 'The expected error message should have been generated');
    }

    @IsTest
    private static void itShouldgetFromCacheMapIdString(){
        Id fakeId = TestFactory.getFakeId(RecordType.getSObjectType());
        Map<Id, String> values = new Map<Id, String>{
            fakeId => 'stringValue'
        };

        RecordTypeService.cache.put('cacheKey', values);

        Test.startTest();
        Map<Id, String> result = RecordTypeService.getFromCacheMapIdString('cacheKey');
        Test.stopTest();

        Assert.areEqual('stringValue', result.get(fakeId), 'The correct value should be returned from the cache');
    }

    @IsTest
    private static void itShouldgetRecordTypeDeveloperNameById(){
        Map<String, RecordTypeInfo> infos = Schema.getGlobalDescribe().get(VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG).getDescribe().getRecordTypeInfosByDeveloperName();
        Map<Id, String> control = new Map<Id, String>();
        for (RecordTypeInfo info :infos.values()){
            if (!info.isActive()){
                continue;
            }
            control.put(info.getRecordTypeId(), info.getDeveloperName());
        }

        Test.startTest();
        Map<Id, String> result = RecordTypeService.getRecordTypeDeveloperNameById(VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG);
        Test.stopTest();

        Assert.areEqual(control.size(), result.size(), 'The same amount of recordtypes should have been located');
    }

    @IsTest
    private static void itShouldCachegetRecordTypeDeveloperNameById(){
        Map<String, RecordTypeInfo> infos = Schema.getGlobalDescribe().get(VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG).getDescribe().getRecordTypeInfosByDeveloperName();
        Map<Id, String> control = new Map<Id, String>();
        for (RecordTypeInfo info :infos.values()){
            if (!info.isActive()){
                continue;
            }
            control.put(info.getRecordTypeId(), info.getDeveloperName());
        }

        Test.startTest();
        Map<Id, String> result = RecordTypeService.getRecordTypeDeveloperNameById(VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG);
        Map<Id, String> result2 = RecordTypeService.getRecordTypeDeveloperNameById(VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG);
        Test.stopTest();

        Assert.isTrue(RecordTypeService.cache.containsKey('getRecordTypeDeveloperNameById' + VALID_OBJECT_WITH_RECORDTYPES_IN_THIS_ORG), 'The correct record should exist in the cache');
    }

    @IsTest
    private static void itShouldGetIdFromCache(){
        Id fakeId = TestFactory.getFakeId(RecordType.getSObjectType());

        RecordTypeService.cache.put('cacheKey', fakeId);

        Test.startTest();
        Id result = RecordTypeService.getFromCacheId('cacheKey');
        Test.stopTest();

        Assert.areEqual(fakeId, result, 'The correct value should be retrieved from the cache');
    }
}
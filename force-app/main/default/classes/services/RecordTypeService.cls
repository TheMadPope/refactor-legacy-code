/*
 * The RecordTypeService provides easy access to RecordType information.
 * Uses a local cache to dramatically improve performance across a single execution
 */
public abstract without sharing class RecordTypeService{

    /**
    * Instance of a local cache to provide already fetched data
    */
    @testVisible
    private static Map<String, object> cache {
        get{
            if (cache==null){
                cache = new Map<String, object>();
            }
            return cache;
        }
        set;
    }

    /**
    * Returns a cached Id
    * @param cacheKey (String): The key by which the data is stored in the cache
    * @return Id: requested data
    */
    @testVisible
    private static Id getFromCacheId(String cacheKey){
        object result = cache.get(cacheKey);
        return result==null ? null : (Id)result;
    }

    /**
    * Returns a cached RecordType
    * @param cacheKey (String): The key by which the data is stored in the cache
    * @return RecordType: requested data
    */
    @testVisible
    private static RecordType getFromCacheRecordType(String cacheKey){
        object result = cache.get(cacheKey);
        return result==null ? null : (RecordType)result;
    }

    /**
    * Returns a cached List<RecordType>
    * @param cacheKey (String): The key by which the data is stored in the cache
    * @return List<RecordType>: requested data
    */
    @testVisible
    private static List<RecordType> getFromCacheRecordTypeList(String cacheKey){
        object result = cache.get(cacheKey);
        return result==null ? null : (List<RecordType>)result;
    }

    /**
    * Returns a cached Map<String, Id>
    * @param cacheKey (String): The key by which the data is stored in the cache
    * @return Map<String, Id>: requested data
    */
    @testVisible
    private static Map<String, Id> getFromCacheMapStringId(String cacheKey){
        object result = cache.get(cacheKey);
        return result==null ? null : (Map<String, Id>)result;
    }

    /**
    * Returns a cached Map<String, Id>
    * @param cacheKey (String): The key by which the data is stored in the cache
    * @return Map<String, Id>: requested data
    */
    @testVisible
    private static Map<Id, String> getFromCacheMapIdString(String cacheKey){
        object result = cache.get(cacheKey);
        return result==null ? null : (Map<Id, String>)result;
    }

    /**
    * Gets the requested record Type Id
    * @param objectName (String): The object to examine
    * @param recordTypeDeveloperName (String): the record type's developer name
    * @return RecordTypeId: requested data
    */
    public static Id getRecordTypeId(String objectName, String recordTypeDeveloperName){
        //NOTE: Not caching as that (and error handling) is done by the inner method
        return getRecordType(objectName, recordTypeDeveloperName).Id;
    }

    /**
    * Gets the requested RecordType
    * @param objectName (String): The object to examine
    * @param recordTypeDeveloperName (String): the record type's developer name
    * @return RecordType: requested data
    */
    public static RecordType getRecordType(String objectName, String recordTypeDeveloperName){
        String cacheKey = String.join(new List<String>{'getRecordType', objectName, recordTypeDeveloperName}, '');
        RecordType result = getFromCacheRecordType(cacheKey);
        if (result!=null){
            return result;
        }
        try{
            RecordTypeInfo info = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName);
            result = new RecordType(
                Name = info.getName(),
                Id = info.getRecordTypeId()
            );
        } catch (Exception e){
            throw new ServiceException('Unable to find RecordType for object ' + objectName + ' with DeveloperName of ' + recordTypeDeveloperName);
        }
        cache.put(cacheKey, result);
        return result;
    }

    /**
    * Gets a list of all record types for the requested object
    * @param objectName (String): The object to examine
    * @return List<RecordType>: requested data
    */
    public static List<RecordType> getRecordTypeList(String objectName){
        String cacheKey = String.join(new List<String>{'getRecordTypeList', objectName}, '');
        List<RecordType> result = getFromCacheRecordTypeList(cacheKey);
        if (result!=null){
            return result;
        }
        result = new List<RecordType>();
        Map<String, RecordTypeInfo> infos = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName();
        for (RecordTypeInfo info :infos.values()){
            if (!info.isActive()){
                continue;
            }
            result.add(
                new RecordType(
                    Name = info.getName(),
                    Id = info.getRecordTypeId(),
                    DeveloperName = info.getDeveloperName()
                )
            );
        }
        cache.put(cacheKey, result);
        return result;
    }

    /**
    * Gets a map of RecordTypeIds, with the Developer Name as the Key
    * @param objectName (String): The object to examine
    * @return Map<String, Id>: requested data
    */
    public static Map<String, Id> getRecordTypeIdByDeveloperName(String objectName){
        String cacheKey = String.join(new List<String>{'getRecordTypeIdByDeveloperName', objectName}, '');
        Map<String, Id> result = getFromCacheMapStringId(cacheKey);
        if (result!=null){
            return result;
        }
        Map<String, RecordTypeInfo> infos = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName();
        result = new Map<String, Id>();
        for (RecordTypeInfo info :infos.values()){
            if (!info.isActive()){
                continue;
            }
            result.put(info.getDeveloperName(), info.getRecordTypeId());
        }
        cache.put(cacheKey, result);
        return result;
    }

    /**
    * Gets a map of RecordTypeIds, with the Developer Name as the Key
    * @param objectName (String): The object to examine
    * @return Map<String, Id>: requested data
    */
    public static Map<Id, String> getRecordTypeDeveloperNameById(String objectName){
        String cacheKey = String.join(new List<String>{'getRecordTypeDeveloperNameById', objectName}, '');
        Map<Id, String> result = getFromCacheMapIdString(cacheKey);
        if (result!=null){
            return result;
        }
        Map<String, RecordTypeInfo> infos = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName();
        result = new Map<Id, String>();
        for (RecordTypeInfo info :infos.values()){
            if (!info.isActive()){
                continue;
            }
            result.put(info.getRecordTypeId(), info.getDeveloperName());
        }
        cache.put(cacheKey, result);
        return result;
    }
}
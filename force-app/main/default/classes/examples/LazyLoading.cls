public without sharing abstract class LazyLoading {

    /**
     * Lazily loads the Account Standard RecordType Id.
     * This leaves it null until it's first invoked, then it uses the Service to populate the value.
     * This can be handy for class level variables that you cannot easily move into a method.
     * I tend to use this approach for record types quite a bit.
     * And of course note that I'm using the RecordTypeService to get the advantages from that.
     */
    @testVisible
    private static Id RECORDTYPE_ID_ACCOUNT_STANDARD {
        get {
            if (RECORDTYPE_ID_ACCOUNT_STANDARD == null) {
                RECORDTYPE_ID_ACCOUNT_STANDARD = RecordTypeService.getRecordTypeId('Account', 'Standard');
            }
            return RECORDTYPE_ID_ACCOUNT_STANDARD;
        }
        private set;
    }
}
public class cntrAddCustomMeasures {
    /*
Description: This is the controller for the AddCustomMeasures page. It will be
mainly called from an Opportunity or Rebate record accepting an ID respectively
so that the selected Measures can be associated but in a case where a Measure
is selected, a Measure record does not yet exist and will be created and then we will
associate the opportunity or rebate record to that measure.

Date        Author      Case    Description
--------------------------------------------
05/03/2019 rmoore Moved to API v45
10/24/2013  ldavis              udpated to filter measures being presented to contractor in the portal
09/09/2013  ldavis              updated to diplay measures in portal for contract reservation requests
05/01/2012  llatimer    19695   Added method to prevent Measures from being put on Rebate if flag at VD is set
04/24/2012  llatimer    20993   Corrected error in SOQL when selecting Opp Measures
04/11/2012  llatimer    19312   Added method to prevent non Rebating Measures from being put on Rebate if flag at PM is set
03/18/2012  llatimer    18507   Added Opp Name to the page for Opp Measures
03/07/2012  llatimer    18263   Changed reference in Account to the Grocery Climate Zone
03/05/2012  llatimer    18725   Added reference to Account when looking for Opp Measures
02/29/2012  llatimer    14734   Fixed bugs for Residential
02/23/2012  llatimer            Added criteria to make sure the hierarchy for Measure is Active
02/18/2011  llatimer            Modfied page and controller to work for Res and Grocery
02/06/2011  llatimer            Added method to identify the poper Record Type for Measure
02/05/2011  llatimer    10902   Populated Account Id when null for Audit and Opp/ Reb
12/21/2011  llatimer            Added criteria to make sure Program Measure is Active when selecting
new Measures
12/07/2011  llatimer            Added the population of the Account Id to the meausure
09/09/2011  llatimer            Test Method completed 88%
09/02/2011  llatimer            Added criteria to make sure Recommended Measures returned from Audit are active
08/17/2011  llatimer            Added criteria to selecting Prog Measures to only include Deemed.
Also allowed "All", "All" VD to show on page even if CZ and Vintage is
not populated in the Account.
07/31/2011  llatimer            Fixed the inline editing and set defaults
07/29/2011  llatimer            Renamed total fields
07/29/2011  llatimer            Populating VD Id and Estimated Count for new Measure
07/28/2011  llatimer            Fixed some SQL for an Active flag and order by
07/21/2011  llatimer            Changed some functionality for the user including radio buttons
07/18/2011  llatimer            Changed null values for CZ and Vintage to All. This is a workaround
and should not stay.
07/12/2011  llatimer            Fixed reference to Audit when one does not exist
07/07/2011  llatimer            Changed sql from Measure to Program Measure
12/28/2010  anguyen             Created
*/

    private id idO, idR, idP, idPRType;
    public list<containerOfMeas> lstAMeas { get; private set; }
    public list<containerOfMeas> lstOMeas { get; private set; }
    public list<containerOfMeas> lstVMeas { get; private set; }
    public list<containerOfMeas> lstMeas { get; private set; }
    public list<Utility_Approved_Measure__c> lstUtilApprvdMeas {get; private set; }
    public list<id> lstUtilApprvdIds {get; private set; }

    private id idAcct { get; set; }
    public id idBaseMeasure { get; set; }
    public string strCategory { get; set; }
    public string strPName { get; private set; }
    public string strMeasSource { get; set; }
    public string[] lstIncModeled { get; set; }
    public string strAName { get; private set; }
    public datetime dtADate { get; private set; }


    public boolean blnShowContinue { get; private set; }
    public boolean blnShowAudit { get; private set; }
    public boolean blnShowOpp { get; private set; }
    public boolean blnShowPMeas { get; private set; }
    public boolean blnShowPMeasFund { get; private set; }
    public boolean blnShowPMCat { get; private set; }
    public boolean blnShowIncMod { get; private set; }
    public boolean blnShowRadio { get; private set; }
    public boolean blnShowInstalled { get; set; }
    public boolean blnShowEstimated { get; set; }
    public RecordType myRec { get; set; }
    private boolean blnShowOppCheckBox;
    private boolean blnIncModeled;
    private boolean blnIsOpp;
    private boolean isResRequest;
    private string strLOB;

    public static list<RecordType> lstOppRecordTypes {get;set;}
    public static list<RecordType> lstRebRecordTypes {get;set;}
    public static set<Id> lstResidentialRecordTypeId {get;set;}
    public static set<Id> lstResOppRecordTypeId {get;set;}
    public static map<ID, RecordType> mapOppRecType {get;set;}
    public static map<ID, RecordType> mapRebRecType {get;set;}
    public static map<ID, RecordType> mapMeasRecType {get;set;}

    public static void GetRecordTypes () {
        mapOppRecType = clsUtl.getRecordTypeObjectsBySObjectType('Opportunity');
        mapRebRecType = clsUtl.getRecordTypeObjectsBySObjectType('Rebate_COM__c');
        mapMeasRecType = clsUtl.getRecordTypeObjectsBySObjectType('Measure__c');
        lstResOppRecordTypeId = new set<id>();
        for (RecordType x: mapOppRecType.values()) {
            system.debug(logginglevel.ERROR,'************************* Opp Record Types: x.Name: '+ x.Name);
            if (x.Name.contains('Residential Multifamily')) { //may add additional record types later
                lstResOppRecordTypeId.add(x.id);
            }
        }
        system.debug(logginglevel.ERROR,'************************* Opp Record Types: lstResOppRecordTypeId: '+ lstResOppRecordTypeId);
    }



    public cntrAddCustomMeasures () {
        GetRecordTypes();

        idO = ApexPages.currentPage().getParameters().get('oId');  // Opportunity Id
        idR = ApexPages.currentPage().getParameters().get('rId');  // Rebate Id

        blnShowOpp = false;
        blnShowOppCheckBox = true;
        blnShowInstalled = false;
        blnIncModeled = false;
        isResRequest = false;
        blnShowContinue = true;

        if (idO <> null) {
            blnShowOppCheckBox = false;
            blnIsOpp = true;
            blnShowEstimated = true;
        } else if (idR <> null ) {
            blnIsOpp = false;
            blnShowInstalled = true;
        }

        id idParentRT;
        if (idO != null) {
            Opportunity objO = [select Program_Id__c, Program_Id__r.RecordTypeId, RecordTypeId, Reservation_Status__c, Store_Utility__c
                                from Opportunity where id = :idO];
            idP = objO.Program_Id__c;
            if (objO.Store_Utility__c != null) {
                lstUtilApprvdMeas = [select Utility__c, Program_Measure__c, Utility_Name__c from Utility_Approved_Measure__c where Utility_Name__c = :objO.Store_Utility__c];
                lstUtilApprvdIds = new list<id>();
                for (Utility_Approved_Measure__c x :  lstUtilApprvdMeas) {
                    lstUtilApprvdIds.add(x.Program_Measure__c);
                }
            }
            idParentRT = objO.Program_Id__r.RecordTypeId;
            myRec = [select id from RecordType where SobjectType  = 'Opportunity' and Name = 'Reservation Request'];
            if (myRec.Id == objO.RecordTypeId) {
                isResRequest = true;
                if (objO.Reservation_Status__c != 'Pending') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Reservation Request is no longer pending therefore, it cannot be modified.'));
                    blnShowContinue = false;
                    return;
                }
            }
        }
        if (idR != null) {
            Rebate_COM__c objR = [select Program_Id_COM__c, Program_Id_COM__r.RecordTypeId
                                  from Rebate_COM__c where Id = :idR];
            idP = objR.Program_Id_COM__c;
            idParentRT = objR.Program_Id_COM__r.RecordTypeId;
        }

        if (idP == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A Program has not been defined for the parent record.'));
            return;
        }

        if (isResRequest) {
            strLOB = 'Residential';
        } else {
            strLOB = clsUtl.getLobById(String.valueOf(idParentRT));
        }
        system.debug('RecordType: ' + strLOB);

        if (strLOB.equalsIgnoreCase('grocery')) {
            blnShowRadio = true;
            blnShowIncMod = true;
            blnShowAudit = true;
            blnShowPMeas = false;
            blnShowPMeasFund = false;
        } else if (strLOB.equalsIgnoreCase('Residential')){
            blnShowRadio = false;
            blnShowIncMod = false;
            blnShowAudit = false;
            blnShowPMeas = true;
            blnShowPMeasFund = false;
            blnShowPMCat =  true;
        } else {
            blnShowRadio = false;
            blnShowIncMod = false;
            blnShowAudit = false;
            blnShowPMeas = true;
            blnShowPMeasFund = true;
        }
        buildWrapper();
    }

    public void buildWrapper() {
        string strClimateZone;
        string strVintage;
        string strAccountName;

        if (idR <> null) {
            Rebate_COM__c objReb = [select Id, Name, Program_Id_COM__c, Program_Id_COM__r.Name, Customer_Account_COM__c,
                                    Customer_Account_COM__r.Grocery_Climate_Zone__c, Customer_Account_COM__r.Vintage__c,
                                    Customer_Account_COM__r.Name,
                                    Program_Id_COM__r.RecordTypeId
                                    from Rebate_COM__c where Id = :idR limit 1];

            idP = objReb.Program_Id_COM__c;
            idPRType = objReb.Program_Id_COM__r.RecordTypeId;
            strClimateZone = objReb.Customer_Account_COM__r.Grocery_Climate_Zone__c;
            strVintage = objReb.Customer_Account_COM__r.Vintage__c;
            strAccountName = objReb.Customer_Account_COM__r.Name;
            idAcct = objReb.Customer_Account_COM__c;
            strPName = objReb.Program_Id_COM__r.Name;
        } else if (idO <> null) {
            Opportunity objOpp = [select Id, Name, Program_Id__c, Program_Id__r.Name,
                                  AccountId , Account.Grocery_Climate_Zone__c, Account.Vintage__c, Account.Name,
                                  Program_Id__r.RecordTypeId
                                  from Opportunity where id = :idO limit 1];

            idP = objOpp.Program_Id__c;
            idPRType = objOpp.Program_Id__r.RecordTypeId;
            strClimateZone = objOpp.Account.Grocery_Climate_Zone__c;
            strVintage = objOpp.Account.Vintage__c;
            strAccountName = objOpp.Account.Name;
            idAcct = objOpp.AccountId;
            strPName = objOpp.Program_Id__r.Name;
        }
        // //system.debug('Vintage: ' + strVintage + '/ ClimateZone: ' + strClimateZone+ '/ Program: ' + idP);

        // Display Audit Measures
        if (blnShowAudit == true) {
            // //system.debug('Program: ' + idP + ' / Account: ' + idAcct);
            AggregateResult[] groupedResults = [select Customer_ID__c, max(Audit_End_Date__c)
                                                from Audit__c
                                                where Customer_ID__c = :idAcct
                                                and Audit_End_Date__c != null
                                                and Program_ID__c = :idP
                                                group by Customer_ID__c];

            if (groupedResults.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'An Audit was not found for this Account. Or an End Date has not been specified for the Audit.'));
                return;
            }

            datetime dtMaxAudit = Datetime.ValueOf(groupedResults[0].get('expr0'));
            // //system.debug('AuditDate: ' + dtMaxAudit);

            Audit__c objAud = [select Id, Name, Auditor_ID__r.Alias, Audit_Begin_Date__c, Audit_End_Date__c, Program_ID__r.Name
                               from Audit__c
                               where Customer_ID__c = :idAcct
                               and Audit_End_Date__c = :dtMaxAudit limit 1];
            // //system.debug('AuditId: ' + objAud.Id + '/ ProgramId: ' + idP);

            id idAud = objAud.Id;
            strAName = objAud.Auditor_ID__r.Alias;
            dtADate = objAud.Audit_End_Date__c;

            lstAMeas = new list<containerOfMeas>();
            string strSQL = 'select Id, Name, Installed_Count_S__c, Recommended_Count__c, Client_Measure_Number__c, Recommended_kWh_per_Unit__c, Recommended_kW_per_Unit__c, ';
            strSQL += 'Rebate_id__c, Total_cost__c, Recommended_Amount_per_Unit__c, Audit_ID__r.Name, ';
            strSQL += 'Total_Recommended_Amount_Calc__c, Total_Recommended_kWh_Calc__c, Estimated_Count__c ';
            strSQL += 'from Measure__c where Audit_ID__c = \'' + idAud + '\' and Opportunity_Id__c = null ';
            strSQL += 'and Rebate_Id__c = null and Variant_Detail_ID__r.Program_Measure_Id__r.Program__c = \'' + idP + '\' ';
            strSQL += 'and Variant_Detail_ID__r.Variant_Master_Id__r.Active__c = true ';
            strSQL += 'and Variant_Detail_ID__r.Program_Measure_Id__r.Active__c = true ';
            if (!blnIsOpp) { strSQL += 'and Variant_Detail_ID__r.Program_Measure_Id__r.Allow_Measure_to_Rebate__c = true and Variant_Detail_ID__r.Allow_Measure_to_Rebate__c = true '; }
            strSQL += 'order by Name';

            //system.debug(logginglevel.ERROR,'****ONE******* Opp Measure Query string: strSQL: '+ strSQL);
            for (Measure__c Am : database.query(strSQL)) {
                lstAMeas.add(new containerOfMeas(Am));
            }
        }
        // Display Opportunity Measures
        if (blnShowOpp == true) {
            lstOMeas = new list<containerOfMeas>();
            string strSQL = 'select Id, Name, Installed_Count_S__c, Rebate_Id__c, ';
            strSQL += 'Recommended_Count__c, Client_Measure_Number__c, Estimated_Count__c, Opportunity_Id__r.Name, Total_Estimated_kW__c, Total_Estimated_Therms__c, ';
            strSQL += 'Recommended_kWh_per_Unit__c, Recommended_kW_per_Unit__c, Recommended_Amount_per_Unit__c, Estimated_Gallons_per_Unit__c,';
            strSQL += 'Estimated_kWh_per_Unit__c, Estimated_kW_per_Unit__c, Estimated_Amount_per_Unit__c,Estimated_Therms_per_Unit__c, ';
            strSQL += 'Variant_Detail_ID__r.Amount_per_Unit__c, Variant_Detail_ID__r.Contractor_Amount_Per_Unit__c, Variant_Detail_ID__r.Gross_kWh_per_Unit__c, ';
            strSQL += 'Total_Cost__c, Total_Estimated_Amount__c, Total_Estimated_kWh__c, Recommended_Gallons_per_Unit__c, Recommended_Therms_per_Unit__c ';
            strSQL += 'from Measure__c where Opportunity_Id__c <> null ';
            strSQL += 'and Rebate_Id__c = null and Variant_Detail_ID__r.Program_Measure_Id__r.Program__c = \'' + idP + '\' ';
            strSQL += 'and Opportunity_Id__r.AccountId = \'' + idAcct + '\' ';
            strSQL += /*'and Variant_Detail_ID__r.Active__c = true */ ' and Variant_Detail_ID__r.Variant_Master_Id__r.Active__c = true ';
            strSQL += 'and Variant_Detail_ID__r.Program_Measure_Id__r.Active__c = true ';
            if (!blnIsOpp) {
                strSQL += 'and Variant_Detail_ID__r.Program_Measure_Id__r.Allow_Measure_to_Rebate__c = true ';
                strSQL += 'and Variant_Detail_ID__r.Allow_Measure_to_Rebate__c = true ';
            }
            if (strCategory <> null) {
                strSQL += 'and Program_Measure_Id__r.Category__c = \'' + strCategory + '\' ';
            }
            strSQL += 'order by Name';
            //system.debug(logginglevel.ERROR,'****TWO******* Opp Measure Query string: strSQL: '+ strSQL);

            for (Measure__c Om : database.query(strSQL)) {
                lstOMeas.add(new containerOfMeas(Om));
            }
        }
        // Display Program Measures
        if (blnShowPMeas == true) {
            // Make sure Climate Zone and Vintage are populated
            ////system.debug(logginglevel.ERROR, '************************ lstResOppRecordTypeId.size(): '+lstResOppRecordTypeId.size());
            if (!isResRequest && (lstResOppRecordTypeId == null)) {
                if ((strClimateZone == null) || (strVintage == null)) {
                    string strErr = 'Either Climate Zone and/or Vintage in Account (' + strAccountName + ') is not populated. All possible records may not have returned.';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, strErr));
                }
            }

            lstVMeas = new list<containerOfMeas>();
            if (lstIncModeled == null) lstIncModeled = new list<string>();
            set<string> setStrVDtl = new set<string>();

            string strSQL = 'select Id, Name,RecordType.DeveloperName, Program_Measure_ID__r.Name, Client_Measure_Number__c, Client_Measure_Name__c, Climate_Zone__c, Vintage__c, ';
            strSQL += 'kW_per_Unit__c, Therms_per_Unit__c, Gallons_per_Unit__c, Program_Measure_Id__r.Calculation_Type__c, ';
            strSQL += 'kWh_per_Unit__c, Amount_per_Unit__c, Variant_Master_Id__r.Name from Variant_Detail__c ';
            //            strSQL += 'where Active__c = true and /*Variant_Master_Id__r.Active__c = true and*/ Program_Measure_Id__r.Active__c = true ';
            strSQL += 'where Active__c = true and Program_Measure_Id__r.Active__c = true ';
            strSQL += 'and Program_Measure_Id__r.Program__c = :idP ';

            if (isResRequest) { strSQL += 'and Client_Measure_Number__c != null and Client_Measure_Number__c != \' \' AND (Program_Measure_Id__r.Calculation_Type__c = \'' + gblConstants.ProgramMeasureCalculationType_DeemedSaving() + '\'  OR Program_Measure_Id__r.Calculation_Type__c = \'' + gblConstants.ProgramMeasureCalculationType_Custom() + '\') '; }
            if (!blnIsOpp) {
                strSQL += 'and (Allow_Measure_to_Rebate__c = true) ';
                strSQL += 'and (Program_Measure_Id__r.Allow_Measure_to_Rebate__c = true) ';
            }
            if (!blnIncModeled && !isResRequest) {
                strSQL += 'and Program_Measure_Id__r.Calculation_Type__c = \'' + gblConstants.ProgramMeasureCalculationType_DeemedSaving() + '\' ';
            }
            if (strCategory <> null) { strSQL += 'and Program_Measure_Id__r.Category__c = \'' + strCategory + '\' '; }
            if (idBaseMeasure <> null) { strSQL += 'and Program_Measure_Id__r.Base_Measure_ID__c = \'' + idBaseMeasure + '\' order by Variant_Master_Id__r.Name, Program_Measure_ID__r.Name';
                                       } else {
                                           strSQL += 'order by Variant_Master_Id__r.Name, Program_Measure_ID__r.Name';
                                       }
            //system.debug(logginglevel.ERROR,'****THREE******* Opp Measure Query string: strSQL: '+ strSQL);
            //system.debug('SQL: ' + strSQL);
            list<Variant_Detail__c> lstVD = database.query(strSQL);
            if (lstVD.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Program Measures were not found for ' + strPName + '.'));
                return;
            }
            for (Variant_Detail__c vD : lstVD) {
                if( (vD.RecordType.DeveloperName=='Residential')){
                    if (!setStrVDtl.contains(vD.Name)) {
                        setStrVDtl.add(vD.Name);
                        lstVMeas.add(new containerOfMeas(vD));
                    }
                } else if ((vd.Vintage__c == null) || (vD.Climate_Zone__c == null)) {
                    string strErr = 'Either Climate Zone and/or Vintage in Variant Detail (' + vD.Name + ') is not populated. All possible records may not have returned.';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, strErr));
                } else if (vD.RecordType.DeveloperName=='Grocery'&&(vD.Vintage__c.equalsIgnoreCase(strVintage) || vD.Vintage__c.equalsIgnoreCase('All')) &&
                           (vD.Climate_Zone__c.equalsIgnoreCase(strClimateZone) || vD.Climate_Zone__c.equalsIgnoreCase('All'))) {
                               if (!setStrVDtl.contains(vD.Name)) {
                                   setStrVDtl.add(vD.Name);
                                   lstVMeas.add(new containerOfMeas(vD));
                               }

                           }
            }
            //system.debug('#####setStrVDtl.size###'+setStrVDtl.size());
        }
    }


    public PageReference incModeled() {
        blnIncModeled = !lstIncModeled.isEmpty() ;
        buildWrapper();
        return null;
    }

    public list<SelectOption> getOptionsBMeas() {
        list<string> lstRT = clsUtl.getIdsByLob(strLOB);
        list<SelectOption> options = new list<SelectOption>();
        set<id> setId = new set<id>();
        options.add(new SelectOption('', '-- None --'));
        for (Program_Measure__c pM: [select Base_Measure_Id__r.Id, Base_Measure_Id__r.Name
                                     from Program_Measure__c
                                     where Program__c = :idP
                                     and RecordTypeId in :lstRT
                                     order by Base_Measure_Id__r.Name]) {
                                         if (!setId.contains(pM.Base_Measure_Id__r.Id)) { // Keeps duplicates out of Options
                                             setId.add(pM.Base_Measure_Id__r.Id);
                                             options.add(new SelectOption(pM.Base_Measure_Id__r.id, pM.Base_Measure_Id__r.Name));
                                         }
                                     }
        return options;
    }

    public list<SelectOption> getOptionsPMCats() {
        list<string> lstRT = clsUtl.getIdsByLob(strLOB);
        list<SelectOption> options = new list<SelectOption>();
        set<string> setStr = new set<string>();
        options.add(new SelectOption('', '-- None --'));
        for (Program_Measure__c pM: [select Category__c
                                     from Program_Measure__c
                                     where Program__c = :idP
                                     and RecordTypeId in :lstRT
                                     order by Category__c]) {
                                         if (!setStr.contains(pM.Category__c)) { // Keeps duplicates out of Options
                                             setStr.add(pM.Category__c);
                                             options.add(new SelectOption(pM.Category__c, pM.Category__c));
                                         }
                                     }
        return options;
    }
    public list<SelectOption> getChkItems() {
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('true', 'Include Modeled'));
        return options;
    }

    public list<SelectOption> getRadioItems() {
        if (strLOB.equalsIgnoreCase('grocery')) {
            if (strMeasSource == null) strMeasSource = 'Aud';
        } else {
            if (strMeasSource == null) strMeasSource = 'PMeas';
        }
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('Aud','Audit Recommended Measures'));
        options.add(new SelectOption('PMeas', 'Program Measures'));
        if (blnShowOppCheckBox == true) {
            options.add(new SelectOption('Opp', 'Opportunity Measures'));
        }
        return options;
    }

    public PageReference GetMeasures() {
        blnShowAudit = false;
        blnShowOpp = false;
        blnShowPMeas = false;

        if (!strLOB.equalsIgnoreCase('grocery')) strMeasSource = 'PMeas';

        if (strMeasSource == 'Aud') {
            blnShowAudit = true;
        } else if (strMeasSource == 'Opp') {
            blnShowOpp = true;
        } else if (strMeasSource == 'PMeas') {
            blnShowPMeas = true;
        }
        GetRecordTypes();
        buildWrapper();
        return null;
    }

    public PageReference cancel() {
        return getPageRef();
    }

    public static list<RecordType> measRecordTypes {get;set;}
    public static set<Id> measRecordTypeId {get;set;}

    public static void measureGetRecordTypes () {
        measRecordTypes = [select Id, Name from RecordType where sObjectType = 'Measure__c'];
        measRecordTypeId = new set<id>();
        for (RecordType x: measRecordTypes) {
            if (x.name.contains('Residential Opportunity')){
                measRecordTypeId.add(x.id);
            }
        }
    }




    public PageReference save() {
        if (!blnShowContinue){
            return getPageRef();
        }
        measureGetRecordTypes();
        getlstMeas();
        boolean blnMSelected = false;

        if (lstMeas == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Wait for page to populate before pressing Continue.'));
            return GetMeasures();
        }

        for (containerOfMeas cMs : lstMeas) {
            if (cMs.selected == true) {
                //system.debug(logginglevel.ERROR, '******aaaaa************* measRecordTypeId: '+ measRecordTypeId);
                //system.debug(logginglevel.ERROR, '******aaaaa************* cMs.ObjMeas: '+ cMs.ObjMeas);
                if (cMs.ObjMeas != null) {  // case where doing add measure with possible different Estimate_Count__c value
                    if (cMs.objMeas.Recommended_kWh_per_Unit__c !=null) cMs.objMeas.Estimated_kWh_per_Unit__c = cMs.objMeas.Recommended_kWh_per_Unit__c;
                    if (cMs.objMeas.Recommended_kW_per_Unit__c !=null) cMs.objMeas.Estimated_kW_per_Unit__c = cMs.objMeas.Recommended_kW_per_Unit__c;
                    if (cMs.objMeas.Recommended_Therms_per_Unit__c !=null) cMs.objMeas.Estimated_Therms_per_Unit__c = cMs.objMeas.Recommended_Therms_per_Unit__c;
                    if (cMs.objMeas.Recommended_Gallons_per_Unit__c !=null) cMs.objMeas.Estimated_Gallons_per_Unit__c = cMs.objMeas.Recommended_Gallons_per_Unit__c;
                    if (cMs.objMeas.Recommended_Amount_per_Unit__c !=null) cMs.objMeas.Estimated_Amount_per_Unit__c = cMs.objMeas.Recommended_Amount_per_Unit__c;
                    if (cMs.objMeas.Estimated_Count__c == null) cMs.objMeas.Estimated_Count__c = 0;
                    //system.debug(logginglevel.ERROR, '******bbbbbbbbbb************* measRecordTypeId: '+ measRecordTypeId);
                    if (measRecordTypeId == null) {
                        //system.debug(logginglevel.ERROR, '**********1111111********* cMs.objMeas: '+ cMs.objMeas);
                        if (cMs.objMeas.Estimated_Amount_per_Unit__c !=null) cMs.objMeas.Total_Estimated_Amount__c = cMs.objMeas.Estimated_Count__c*clsUtl.nvr(cMs.objMeas.Estimated_Amount_per_Unit__c,0);
                        if (cMs.objMeas.Estimated_kWh_per_Unit__c !=null) cMs.objMeas.Total_Estimated_kWh__c = cMs.objMeas.Estimated_Count__c*clsUtl.nvr(cMs.objMeas.Estimated_kWh_per_Unit__c,0);
                        if (cMs.objMeas.Estimated_Gross_kWh_per_Unit__c !=null) cMs.objMeas.Total_Estimated_Gross_kWh__c = cMs.objMeas.Estimated_Count__c*clsUtl.nvr(cMs.objMeas.Estimated_Gross_kWh_per_Unit__c,0);
                        if (cMs.objMeas.Estimated_Amount_per_Unit__c !=null) cMs.objMeas.Total_Estimated_kW__c = cMs.objMeas.Estimated_Count__c*clsUtl.nvr(cMs.objMeas.Estimated_kW_per_Unit__c,0);
                        if (cMs.objMeas.Estimated_Therms_per_Unit__c !=null) cMs.objMeas.Total_Estimated_Therms__c = cMs.objMeas.Estimated_Count__c*clsUtl.nvr(cMs.objMeas.Estimated_Therms_per_Unit__c,0);
                        if (cMs.objMeas.Estimated_Gallons_per_Unit__c !=null) cMs.objMeas.Total_Estimated_Gallons__c = cMs.objMeas.Estimated_Count__c*clsUtl.nvr(cMs.objMeas.Estimated_Gallons_per_Unit__c,0);
                    } else {
                        //system.debug(logginglevel.ERROR, '**********2222222********* cMs.objMeas: '+ cMs.objMeas);
                        if (cMs.objMeas.Variant_Detail_ID__r.Amount_per_Unit__c !=null) cMs.objMeas.Estimated_Amount_per_Unit__c = cMs.objMeas.Variant_Detail_ID__r.Amount_per_Unit__c;
                        if (cMs.objMeas.Variant_Detail_ID__r.Contractor_Amount_Per_Unit__c !=null) cMs.objMeas.Estimated_Contractor_Amount_Per_Unit__c = cMs.objMeas.Variant_Detail_ID__r.Contractor_Amount_Per_Unit__c;
                        if (cMs.objMeas.Variant_Detail_ID__r.Gross_kWh_per_Unit__c !=null) cMs.objMeas.Estimated_Gross_kWh_per_Unit__c = cMs.objMeas.Variant_Detail_ID__r.Gross_kWh_per_Unit__c;

                        if (cMs.objMeas.Estimated_Amount_per_Unit__c !=null) cMs.objMeas.Total_Estimated_Amount__c = cMs.objMeas.Estimated_Count__c*clsUtl.nvr(cMs.objMeas.Estimated_Amount_per_Unit__c,0);
                        if (cMs.objMeas.Estimated_Contractor_Amount_Per_Unit__c !=null) cMs.objMeas.Total_Estimated_Contractor_Amount__c = cMs.objMeas.Estimated_Count__c*clsUtl.nvr(cMs.objMeas.Estimated_Contractor_Amount_Per_Unit__c,0);
                        if (cMs.objMeas.Estimated_Gross_kWh_per_Unit__c !=null) cMs.objMeas.Total_Estimated_Gross_kWh__c = cMs.objMeas.Estimated_Count__c*clsUtl.nvr(cMs.objMeas.Estimated_Gross_kWh_per_Unit__c,0);

                    }
                }
                blnMSelected = true;
            }
        }

        // add validation that a measure was selected
        if (!blnMSelected ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Unable to Continue because no Measure has been selected.'));
            return null;
        }

        /* Associate the measures to the Opportunity or a Rebate */
        PageReference pgRef;
        if (blnShowAudit == true) {
            pgRef = processAMeas();
        } else if (blnShowOpp == true) {
            pgRef = processOMeas();
        } else if (blnShowPMeas == true) {
            pgRef = processPMeas();
        }
        return pgRef;
    }

    private PageReference processAMeas() {
        list <Measure__c> lstUpdMeas = new list<Measure__c>();
        for (containerOfMeas m : lstAMeas ) {
            if (m.selected == true) {
                if (idO <> null) {
                    m.objMeas.Opportunity_id__c = idO;
                } else if (idR <> null) {
                    m.objMeas.Rebate_id__c = idR;
                }
                if (m.objMeas.Account_Id__c == null) m.objMeas.Account_Id__c = idAcct;
                lstUpdMeas.add(m.objMeas);
            }
        }
        if (!lstUpdMeas.isEmpty()) database.update(lstUpdMeas, true);
        return getPageRef();
    }

    private PageReference processOMeas() {
        //system.debug(logginglevel.ERROR, '**************** In processOMeas()');
        list <Measure__c> lstUpdMeas = new list<Measure__c>();
        for (containerOfMeas m : lstOMeas ) {
            //system.debug(logginglevel.ERROR, '**************** In processOMeas()111');
            if (m.selected == true) {
                //system.debug(logginglevel.ERROR, '**************** In processOMeas()222');
                if (idO <> null) {
                    m.objMeas.Opportunity_id__c = idO;
                } else if (idR <> null) {
                    m.objMeas.Rebate_id__c = IdR;
                }
                if (m.objMeas.Account_Id__c == null) m.objMeas.Account_Id__c = idAcct;
                lstUpdMeas.add(m.objMeas);
            }
        }
        if (!lstUpdMeas.isEmpty()) {
            //system.debug(logginglevel.ERROR, '**************** In processOMeas()333');
            database.update(lstUpdMeas, true);
        }
        return getPageRef();
    }

    // Gets the proper Record Type for the Measure from the Custom Settings object
    private id getRTypeId(id idPgmRT) {
        id idRType;
        try {
            string strPgmRT = String.valueOf(idPgmRT).substring(0, 15);
            string strSLOB = Record_Type__c.getInstance(strPgmRT).Sub_Line_of_Business__c;
            if (strLOB.contains('Residential')) strSLOB = 'Residential Opportunity';
            for (Record_Type__c rt : Record_Type__c.getAll().values()) {
                if ((rt.Sub_Line_of_Business__c == strSLOB) && (rt.Record_Type_Object__c == 'Measure__c')) {
                    idRType = rt.Name;
                }
            }
        } catch (Exception e) {
            idRType = null;
        }
        return idRType;
    }

    private PageReference processPMeas() {
        // Determine Measure Record Type
        id idMRType = getRTypeId(idPRType);
        if (idMRType == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not identify the Record Type for the Measure: ' + idPRType));
            return null;
        }
        /* Create and Associate the measures to the new Opportunity or Rebate */
        list<Measure__c> lstInsMeas = new list<Measure__c>();
        for (containerOfMeas m : lstVMeas ) {
            if (m.selected == true) {
                // Create Measure
                Measure__c objMeas = new Measure__c(
                    RecordTypeId = idMRType,
                    Name = m.objVMeas.Program_Measure_id__r.Name,
                    Program_Measure__c = m.objVMeas.Program_Measure_id__c,
                    Opportunity_Id__c = idO,
                    Account_Id__c = idAcct,

                    // Recommended_Count__c = m.dblEstimated_Count,    // Not sure if this is what we want
                    Recommended_Amount_per_Unit__c = m.objVMeas.Amount_per_Unit__c,
                    Recommended_kWh_per_Unit__c = m.objVMeas.kWh_per_Unit__c,
                    Recommended_kW_per_Unit__c = m.objVMeas.kW_per_Unit__c,
                    Recommended_Therms_per_Unit__c = m.objVMeas.Therms_per_Unit__c,
                    Recommended_Gallons_per_Unit__c = m.objVMeas.Gallons_per_Unit__c,

                    Estimated_Count__c = m.dblEstimated_Count,
                    Estimated_Amount_per_Unit__c = m.objVMeas.Amount_per_Unit__c,
                    Estimated_kWh_per_Unit__c = m.objVMeas.kWh_per_Unit__c,
                    Estimated_kW_per_Unit__c = m.objVMeas.kW_per_Unit__c,
                    Estimated_Therms_per_Unit__c = m.objVMeas.Therms_per_Unit__c,
                    Estimated_Gallons_per_Unit__c = m.objVMeas.Gallons_per_Unit__c,

                    Installed_Count_S__c = m.dblInstalled_Count,
                    Installed_Amount_per_Unit__c = m.objVMeas.Amount_per_Unit__c,
                    Installed_kWh_per_Unit__c = m.objVMeas.kWh_per_Unit__c,
                    Installed_kW_per_Unit__c = m.objVMeas.kW_per_Unit__c,
                    Installed_Therms_per_Unit__c = m.objVMeas.Therms_per_Unit__c,
                    Installed_Gallons_per_Unit__c = m.objVMeas.Gallons_per_Unit__c,

                    Reported_Amount_per_Unit__c = m.objVMeas.Amount_per_Unit__c,
                    Reported_kWh_per_Unit__c = m.objVMeas.kWh_per_Unit__c,
                    Reported_kW_per_Unit__c = m.objVMeas.kW_per_Unit__c,
                    Reported_Therms_per_Unit__c = m.objVMeas.Therms_per_Unit__c,
                    Reported_Gallons_per_Unit__c = m.objVMeas.Gallons_per_Unit__c,

                    Variant_Detail_Id__c = m.objVMeas.Id,
                    Rebate_id__c = idR
                );
                lstInsMeas.add(objMeas);
            }
        }
        database.insert(lstInsMeas);
        return getPageRef();
    }

    private list<containerOfMeas> getlstMeas() {
        lstMeas = new list<containerOfMeas>();
        if (blnShowAudit == true) {
            lstMeas = lstAMeas;
        } else if (blnShowOpp == true) {
            lstMeas = lstOMeas;
        } else {
            lstMeas = lstVMeas;
        }
        return lstMeas;
    }

    private PageReference getPageRef() {
        if (idR <> null) {
            return new PageReference('/' + idR);        // assuming user comes here from the rebate record
        } else if (idO <> null) {
            return new PageReference('/' + idO);        // assuming user comes here from  the opportunity record
        } else { return null; }
    }

    // Container of rebate info
    public class containerOfMeas {
        public Variant_Detail__c objVMeas { get; set; }
        public Measure__c objMeas { get; set; }
        public Boolean selected { get; set; }
        public double dblEstimated_Count { get; set; }
        public double dblInstalled_Count { get; set; }

        public containerOfMeas(Variant_Detail__c objVM) {
            objVMeas = objVM;
            this.selected = false;
            dblEstimated_Count = 0;
            dblInstalled_Count = 0;
        }

        public containerOfMeas(Measure__c objM) {
            objMeas = objM;
            this.selected = false;
        }
    }
}

public with sharing class OpportunityEditForm_Ctrl {
    private static Map<String, Schema.FieldSet> fieldSetMap;
    
    @AuraEnabled
    public static FieldSetForm getForm(Id recordId, String objectName, String fieldSetName) {
        
        getObjectFieldSets(objectName);
        FieldSetForm form = new FieldSetForm();
        try{
            form.products = [SELECT Id, Product2.Name, Quantity, UnitPrice, ServiceDate, Description 
                               FROM OpportunityLineItem WHERE OpportunityId =: recordId];
            
            system.debug('===fieldSetName===='+fieldSetName);
            if(!String.isBlank(fieldSetName)){
                form.fields.addAll(getFields(fieldSetName));
        }
        
        }catch(Exception ex){
            System.debug('--- ' + ex.getMessage() + '--- ' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
        return form;
    }
    
    @AuraEnabled
    public static Id submitUIValues(String jsonObject, String recordId, List<OpportunityLineItem> lstProducts){
        Id returnId = null;
        try{
            System.debug('jsonObject ' + jsonObject);
            System.debug('recordId ' + recordId);
            Opportunity objOPP = (Opportunity) JSON.deserialize(jsonObject, Opportunity.Class);
            Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>{recordId => objOPP};
            system.debug('===mapOpp=='+mapOpp);
            getObjectFieldSets(Id.valueOf(recordId).getSobjectType().getDescribe().getName());
            List<String> lstFields = getFields('Clone_Opportunity_Field_Set');
            
            List<sObject> clonedOppty = SObjectAllFieldCloner.cloneObjects(new List<Id>{recordId}, Opportunity.getsObjectType(), 
                                                                          mapOpp, lstFields);
            if(clonedOppty.isEmpty()){
                return null;
            }
            objOPP = (Opportunity)clonedOppty[0];
            objOPP.Pricebook2Id =  [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id =: recordId].Pricebook2Id;    
            insert objOPP;
            
            Map<Id, OpportunityLineItem> oliMap = new Map<Id, OpportunityLineItem>(lstProducts);
            List<String> lstProductFields = new List<String>{
                'Quantity', 'UnitPrice', 'ServiceDate', 'Description'
            }; 
            List<Sobject> lstSobjectProducts = SObjectAllFieldCloner.cloneObjects(new List<Id>(new Map<Id, OpportunityLineItem>(lstProducts).KeySet()), 
                                                                                                             OpportunityLineItem.getsObjectType(),
                                                                                 oliMap, lstProductFields);
           	
            for(Sobject OLI: lstSobjectProducts){
                OLI.put('OpportunityId', objOPP.Id);
            }
            System.debug('------ lstSobjectProducts' + lstSobjectProducts);
            insert lstSobjectProducts;
            System.debug('------ lstSobjectProducts' + lstSobjectProducts);
            returnId = objOPP.Id;
        }
        catch(Exception ex){
            System.debug('--- ' + ex.getMessage() + '--- ' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
        return returnId;
    }
    
    private static void getObjectFieldSets(String objectName){
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        fieldSetMap = objectDescribe.fieldSets.getMap();
    }
    
    
    private static List<String> getFields( String fieldSetName) {
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
        List<String> fields = new List<String>();
        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            fields.add(fsm.fieldPath);
        }
        return fields;
    }
    
    public class FieldSetForm {
        @AuraEnabled public List<String> fields;
        @AuraEnabled public List<OpportunityLineItem> products;
        public FieldSetForm() {
            fields = new List<String>();
            products = new List<OpportunityLineItem>();
        }
    }
}
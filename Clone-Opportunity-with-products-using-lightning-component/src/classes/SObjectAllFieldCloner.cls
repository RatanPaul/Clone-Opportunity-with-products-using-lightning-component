public class SObjectAllFieldCloner {
    
    // Clone a list of objects to a particular object type
    // Parameters
    // - List<sObject> sObjects - the list of objects to be cloned
    // - Schema.SobjectType objectType - the type of object to be cloned.
    // The sObjects you pass in must include the ID field,
    // and the object must exist already in the database,
    // otherwise the method will not work.
    public static List<sObject> cloneObjects(List<Id> sObjectIds, Schema.SObjectType objectType, 
                                             	Map<Id, Sobject> mapSobject, List<String> lstFields){
        
        // A list of fields for the sObject being cloned
        List<String> sObjectFields = new List<String>();
        // A list of new cloned sObjects
        List<sObject> clonedSObjects = new List<sObject>();
        
        // Get all the fields from the selected object type using
        // the get describe method on the object type.
        if(objectType != null){
            sObjectFields.addAll(objectType.getDescribe().fields.getMap().keySet());
        }
        /* Using the list of sObject IDs and the object type,
		we can construct a string based SOQL query
		to retrieve the field values of all the objects.*/
        
        String allSObjectFieldsQuery = 'SELECT ' + sObjectFields.get(0);
        
        for (Integer i=1 ; i < sObjectFields.size() ; i++){
            allSObjectFieldsQuery += ', ' + sObjectFields.get(i);
        }
        
        allSObjectFieldsQuery += ' FROM ' +
            					objectType.getDescribe().getName() +
            					' WHERE ID IN: sObjectIds' ;
        
        
        System.debug('SOQL **** ' + allSObjectFieldsQuery);
        
        try{
            // Execute the query. For every result returned,
            // use the clone method on the generic sObject
            // and add to the collection of cloned objects
            for (SObject sObjectFromDatabase:Database.query(allSObjectFieldsQuery)){
                Sobject sobjFromCmp = mapSobject.get(sObjectFromDatabase.Id);
                for(String fieldAPI:lstFields){
                    system.debug('===='+fieldAPI);
                    sObjectFromDatabase.put(fieldAPI, sobjFromCmp.get(fieldAPI));
                }
                if(objectType.getDescribe().getName() == 'OpportunityLineItem'){//added this because it was throwing error like we can't provide unitprice and total together
                    sObjectFromDatabase.put('TotalPrice', null);
                }
                clonedSObjects.add(sObjectFromDatabase.clone(false,true));
            }
            System.debug('clonedSObjects **** ' + clonedSObjects);
        } catch (exception e){
            System.debug('======>>'+e);
        }
        return clonedSObjects;
    }
}
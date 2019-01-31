@isTest
public class OpportunityEditForm_Test {
    static testmethod void  testOpportunityForm(){
        Account a1 = new Account(Name ='icrm testing acc');
		insert a1;
		opportunity opp1 = new opportunity(Name='testing DIE 4/6/2015' ,  AccountId= a1.Id,StageName = 'Prospecting', 
                                   				CloseDate = Date.Today().addDays(60));
		insert opp1;
        Id pricebookId = Test.getStandardPricebookId();

        Product2 prod = new Product2(Name = 'Product X',ProductCode = 'Pro-X',isActive = true);
        insert prod;
        
        PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,IsActive = true);
        insert pbEntry;
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp1.Id, Quantity = 5, PricebookEntryId = pbEntry.Id, UnitPrice = 100);
        insert oli;
        OpportunityEditForm_Ctrl.FieldSetForm fldForm = OpportunityEditForm_Ctrl.getForm(opp1.Id, 'Opportunity', 'Clone_Opportunity_Field_Set');
        System.assert(fldForm != null, 'Form should not be empty');
        System.assert(fldForm.products.size() == 1, 'OLI should queried and store in this variable');
        
        opp1.StageName = 'Closed Won';
        
        Id objNewOppId = OpportunityEditForm_Ctrl.submitUIValues(JSON.serialize(opp1), opp1.Id, new List<OpportunityLineItem>{oli});
        System.assert(objNewOppId != null, 'new Opportunity should created here');
        System.assert([SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: objNewOppId].size() == 1, 'OLI should also created under new opportunity');
        System.assert([SELECT StageName FROM Opportunity WHERE Id =: objNewOppId].StageName == 'Closed Won', 
                      	'Opportunity stage should be updated to closed won');
    }
}
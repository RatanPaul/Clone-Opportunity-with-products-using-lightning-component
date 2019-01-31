({
    init: function(cmp, event, helper) {
        cmp.set("v.showSpinner", true);
        console.log('FieldSetFormController.init');
        var sectionfieldSetName = cmp.get('v.sectionfieldSetName');
        var sobjectName = cmp.get('v.sObjectName');
        var recordId = cmp.get('v.recordId');
        
        var getFormAction = cmp.get('c.getForm');
        
        getFormAction.setParams({
            "fieldSetName": sectionfieldSetName,
            "objectName": sobjectName,
            "recordId": recordId
        });
        
        getFormAction.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set("v.showSpinner", false);
            console.log('FieldSetFormController getFormAction callback');
            console.log("callback state: " + state);
            
            if (cmp.isValid() && state === "SUCCESS") { 
                var form = response.getReturnValue();
                console.log("form: " , form);
                cmp.set('v.sectionFields', form.fields);
                cmp.set('v.relatedProducts', form.products);
            }
            else if (state === "INCOMPLETE") {
                helper.showNotifyLibHelper(cmp, 'Error!', 'error', "Unknown error");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        helper.showNotifyLibHelper(cmp, 'Error!', 'error', errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                    helper.showNotifyLibHelper(cmp, 'Error!', 'error', "Unknown error");
                }
            }
            cmp.set("v.showSpinner", false);
        }
                                 );
        $A.enqueueAction(getFormAction);
    },
    onSubmitAction: function(component, event, helper){
        
        event.preventDefault();
        component.set("v.showSpinner", true);
        var recordId = component.get('v.recordId');
        var eventFields = event.getParam("fields");
        var oli = component.get('v.relatedProducts');
        
        var objJSON = JSON.parse(JSON.stringify(eventFields));
        console.log('-------objJSON-----',objJSON);
        
        var recUi = event.getParam("recordUi");
        console.log('-------recUi-----',recUi);
        
        var callAction = component.get("c.submitUIValues");
        
        callAction.setParams({
            "jsonObject": JSON.stringify(eventFields),
            "recordId" : recordId,
            "lstProducts": component.get("v.relatedProducts")
        });
        
        callAction.setCallback(this, function(response){
            var state = response.getState();
            component.set("v.showSpinner", false);
            console.log(state);
            if (state === "SUCCESS") {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": response.getReturnValue(),
                    "slideDevName": "related"
                });
                navEvt.fire();
            }
            else if (state === "INCOMPLETE") {
                helper.showNotifyLibHelper(component, 'Error!', 'error', "Unknown error");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        helper.showNotifyLibHelper(component, 'Error!', 'error', errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                    helper.showNotifyLibHelper(component, 'Error!', 'error', "Unknown error");
                }
            }
        });
        $A.enqueueAction(callAction);
        
    },
    removeOLI: function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var recIndex = selectedItem.dataset.row;
        console.log('====',recIndex);
        var newLstOLIs = [];
        
        var lstOLIs = component.get("v.relatedProducts");
        //if (recIndex > -1) {
            lstOLIs.splice(recIndex, 1);
        //}
        //const filteredItems = lstOLIs.slice(0, recIndex).concat(lstOLIs.slice(recIndex+1, lstOLIs.length));
        component.set("v.relatedProducts", lstOLIs);
    },
    cancelAction: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})
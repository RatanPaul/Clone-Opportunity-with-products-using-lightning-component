({
    showNotifyLibHelper : function(component, msgTitle, msgType, msg) {
        component.find('notifLib').showNotice({
            "variant": msgType,
            "header": msgTitle,
            "message": msg,
            closeCallback: function() {
                console.log('You closed the alert!');
            }
        });
    }
})
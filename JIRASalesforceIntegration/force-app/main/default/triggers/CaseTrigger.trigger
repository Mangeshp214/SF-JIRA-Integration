trigger CaseTrigger on Case (before update) {
    Map<String, String> priorityMap = new Map<String, String>{
        'Very Low' => 'Minor',
        'Low' => 'Minor',
        'Medium' => 'Major',
        'High' => 'Major',
        'Critical' => 'Critical'
    };

    try{

        for(Case c : Trigger.new){

            String oldStatus = Trigger.oldMap.get(c.id).status;
            if(oldStatus == 'Pending On QA' && c.status == 'Pending on SF Dev'){

                String ticketKey = JIRAService.createNewJiraTicket(
                    '<-- Project Key -->', 
                    c.Description, 
                    c.Subject, 
                    null, 
                    priorityMap.get(c.Priority)
                );

                c.JIRA_Ticket__c = ticketKey;

            }

        }

    }catch(Exception e){
        //Intentionally consumed exception. 
    }

}
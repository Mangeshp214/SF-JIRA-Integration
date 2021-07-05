public with sharing class JIRAIntegrationUIController {
    public JIRAIntegrationUIController() {

    }

    // Fetch JIRA ticket based on case number
    @AuraEnabled
    public static string fetchJIRAInfo(String caseNumber){
        
        String returnData = '';
        try{

            if(String.isBlank(caseNumber)){
                throw new ApplicationException('Case number is blank. Cannot fetch JIRA Info.');
            }

            Case relatedCase = [select id, JIRA_Ticket__c from Case where id = :caseNumber limit 1];
            if(relatedCase == null){
                throw new ApplicationException('Case data not found for provided case number : ' + caseNumber);
            }

            JIRATicket ticket = JIRAService.getJIRATicket(relatedCase.JIRA_Ticket__c);
            if(ticket == null || ticket.fields == null){
                throw new ApplicationException('Unable to fetch fields data for ticket from JIRA cloud.');
            }
            
            String latestComment = '';
            if(ticket.fields.comment != null && ticket.fields.comment.comments != null){
                List<JIRATicket.comments> cl = ticket.fields.comment.comments;
                Integer size = cl.size();
                if(!cl.isEmpty() && cl.get(size - 1) != null){
                    latestComment = cl.get(size - 1).body;
                }
            }

            JIRATicketData data = new JIRATicketData(
                ticket.key,
                ticket.fields.summary,
                ticket.fields.description,
                ticket.fields.status != null ? ticket.fields.status.name : '',
                ticket.fields.assignee != null ? ticket.fields.assignee.displayName : '',
                ticket.fields.timeoriginalestimate,
                ticket.fields.created,
                latestComment
            );

            returnData = JSON.serialize(data);

        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        //JSON string of JIRATicketData will be returned on successful execution
        return returnData;

    }

    // Update the information from case UI
    @AuraEnabled
    public static string updateJIRAInfo(String ticketData){
        
        try{

            //JSON string of JIRATicketData is expected in ticketData
            if(String.isBlank(ticketData)){
                throw new ApplicationException('Ticket data is blank.');
            }

            JIRATicketData data = (JIRATicketData) JSON.deserialize(ticketData, JIRATicketData.class);

            JIRAService.updateJiraTicket(data.key, data.summary, data.description, null, data.pendingSince, null);
            
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        //Updated JSON string of JIRATicketData will be returned
        return ticketData;

    }

    public class JIRATicketData{
        @AuraEnabled
        public String key;
        @AuraEnabled
        public String summary;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String assignee;
        @AuraEnabled
        public String estimatedTime;
        @AuraEnabled
        public String pendingSince;
        @AuraEnabled
        public String comment;

        public JIRATicketData(String key, String summary, String description, String status, String assignee, String estimatedTime, String pendingSince, String comment){
            this.key = key;
            this.summary = summary;
            this.description = description;
            this.status = status;
            this.assignee= assignee;
            this.estimatedTime = estimatedTime;
            this.pendingSince = pendingSince;
            this.comment = comment;
        }

    }

}

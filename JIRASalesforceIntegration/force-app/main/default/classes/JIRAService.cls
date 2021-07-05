public with sharing class JIRAService {
    
    private static String jira_host = '<-- Replace with JIRA host -->';
    public enum httpMethod {
        GET,
        PUT,
        POST
    }

    //Create new ticket
    public static String createNewJiraTicket(String project, String description, String summary, String dueDate, String priority){

        JIRATicket ticket = new JIRATicket(project, description, summary, dueDate, priority, null, null);

        Http http = new Http();
        HttpRequest req = createHttpRequest(HttpMethod.POST.name(), '', JSON.serialize(ticket));

        HttpResponse res = http.send(req); 
        if(res.getStatusCode() != 200){
            throw new ApplicationException('Unble to create issue on JIRA cloud. Here is the response returned from JIRA cloud : ' + res);
        }

        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        String ticketKey = (String) response.get('key');

        return ticketKey;

    }

    //Update existing ticket
    public static JIRATicket updateJiraTicket(String ticketKey, String summary, String description, List<String> components, String endDate, List<String> labels){

        JIRATicket ticket = getJIRATicket(ticketKey);

        if(String.isNotBlank(summary)){
            ticket.fields.summary = summary;
        }

        if(String.isNotBlank(description)){
            ticket.fields.description = description;
        }

        if(String.isNotBlank(endDate)){
            ticket.fields.duedate = Date.valueOf(endDate);
        }

        if(labels != null && !labels.isEmpty()){
            ticket.fields.labels = labels;
        }

        if(components != null && !components.isEmpty()){
            List<JIRATicket.Component> newComponents = new List<JIRATicket.Component>();
            for(String name : components){
                newComponents.add(new JIRATicket.Component(name));
            }
            ticket.fields.components = newComponents;
        }

        Http http = new Http();
        HttpRequest req = createHttpRequest(HttpMethod.PUT.name(), ticketKey, JSON.serialize(ticket));

        HttpResponse res = http.send(req); 
        if(res.getStatusCode() != 200){
            throw new ApplicationException('Unble to update issue on JIRA cloud. Here is the response returned from JIRA cloud : ' + res);
        }

        return ticket;

    }

    //fetch ticket
    public static JIRATicket getJIRATicket(String key){

        if(String.isBlank(key)){
            throw new ApplicationException('Jira ticket key is blank');
        }

        Http http = new Http();
        HttpRequest req = createHttpRequest(httpMethod.GET.name(), key, null);
        HttpResponse res = http.send(req); 
        if(res.getStatusCode() != 200){
            throw new ApplicationException('Issue does not exist or user do not have permission to see it. Here is the response returned from JIRA cloud : ' + res);
        }

        String body = res.getBody();

        JIRATicket ticket = (JIRATicket) JSON.deserialize(body, JIRATicket.class);

        return ticket;

    }

    //Save the JIRA authentication information (Username and token)

    //Create HTTP requests
    private static HttpRequest createHttpRequest(String method, String issueKey, String jsonBody){
        
        String url = jira_host + '/rest/api/2/issue/';
        if(httpMethod.PUT.name().equalsIgnoreCase(method) || httpMethod.GET.name().equalsIgnoreCase(method)){
            if(String.isBlank(issueKey)){
                throw new ApplicationException('JIRA ticket key is mandatory while fetching or updating the ticket from JIRA cloud.');
            }
            url = url + issueKey;
        }

        String username = '<-- User Name -->';
        String token = '<-- Token -->';
        String auth_header = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + token));

        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept','application/json');
        req.setHeader('Authorization', auth_header);
        req.setHeader('X-Atlassian-Token', 'nocheck');
        req.setMethod(method);
        req.setEndpoint(url);
        if(! httpMethod.GET.name().equalsIgnoreCase(method))
            req.setBody(jsonBody);

        return req;

    }

}

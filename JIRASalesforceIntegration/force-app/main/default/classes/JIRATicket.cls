public with sharing class JIRATicket {

    public String expand;
    public String id;
    public String self;
    public String key;
    public Fields fields;
    
    public class Fields {

        public Project project;
        public JIRATicket parent;
        public IssueType issuetype;
        public string description;
        public string summary;
        public List<Component> components = new List<Component>{new Component('All')};
        public Date duedate;
        public TimeTrack timetracking;
        public String timeoriginalestimate;
        public Status status;
        public Assignee assignee;
        public String created;
        public Comment comment;
        public String environment;
        public Priority priority;
        public List<String> labels;
        
    }

    public class Priority{
        public String name;
        public Priority(String name){
            this.name = name;
        }
    }

    public Class Comment{
        public List<Comments> comments;
    }

    public Class Comments{
        public String body;
        public Comments(String body){
            this.body = body;
        }
    }
    
    public class Assignee{
        public String displayName;
    }
    
    public class TimeTrack{
        public String remainingEstimate;
        public String remainingEstimateSeconds;
        public String timeSpent;
        public String timeSpentSeconds;
    }
    
    public Class Status{
        public String name;
        public Status(String name){
            this.name = name;
        }
    }
    
    public class Component{
        public String name;
        public Component(String name){
            this.name = name;
        }
    }
    
    public class Project{
        public string key;
        
        public Project(String key){
            this.key = key;
        }
    }
    
    public class IssueType{
        public string id;
        
        public IssueType(String id){
            this.id = id;
        }
    }

    public JIRATicket(){}
    
    public JIRATicket(String key){
        this.key = key;
    }

    public JIRATicket(String project, String description, String summary, String dueDate, String priority, List<String> components, List<String> labels){

        JIRATicket.Fields fields = new JIRATicket.Fields();
        fields.project = new JIRATicket.Project(String.isNotBlank(project) ? project : 'SMI');
        fields.issuetype = new JIRATicket.IssueType('1');
        fields.description = description;
        fields.summary = summary;
        fields.duedate = String.isNotBlank(dueDate) ? Date.valueOf(dueDate) : Date.today().addDays(5);
        fields.priority = new Priority(String.isNotBlank(priority) ? priority : 'Minor');
        fields.labels = labels != null && !labels.isEmpty() ? labels : new List<String>{'customer_case'};
        List<Component> newComponents = new List<Component>();
        for(String name : components){
            newComponents.add(new Component(name));
        }
        fields.components = !newComponents.isEmpty() ? newComponents : new List<Component>{new Component('All')};

    }

}
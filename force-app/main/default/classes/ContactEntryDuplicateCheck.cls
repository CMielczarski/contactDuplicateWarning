public without sharing class ContactEntryDuplicateCheck {
    
    @AuraEnabled(cacheable=true)
    public static list<Contact> getDuplicates(ID id){
            Contact c = new Contact();
            c = [SELECT ID, Email, FirstName, LastName, AccountId FROM Contact WHERE ID =: id];
            string email = c.Email;
            string fName = c.FirstName;
            string lName = c.LastName;
            string accId = c.AccountId;
            list<Contact> duplicates = new list<Contact>();
            string query;
            if(email != null){
                query = 'SELECT ID, Name, Title, Account.Name, Phone, Email, Owner.Name, FirstName, LastName, Is_Contact_Active__c, pi__score__c, pi__grade__c, pi__last_activity__c, pi__notes__c FROM Contact WHERE Is_Contact_Active__c = true AND ID !=: id AND ((Email =: email ) OR (FirstName =: fName AND LastName =: lName AND AccountID =: accId))';
                }
            else{
                query = 'SELECT ID, Name, Title, Account.Name, Phone, Email, Owner.Name, FirstName, LastName, Is_Contact_Active__c, pi__score__c, pi__grade__c, pi__last_activity__c, pi__notes__c FROM Contact WHERE Is_Contact_Active__c = true AND ID !=: id AND FirstName =: fName AND LastName =: lName AND AccountID =: accId';
                }
            duplicates = database.query(query);
            
            return duplicates;        
            }

        @AuraEnabled(cacheable=true)
        public static list<Contact> getDeactivatedDuplicates(ID id){
            Contact c = new Contact();
            c = [SELECT ID, Email, FirstName, LastName, AccountId FROM Contact WHERE ID =: id];
            string email = c.Email;
            string fName = c.FirstName;
            string lName = c.LastName;
            string accId = c.AccountId;
            list<Contact> duplicates = new list<Contact>();
            string query;
            if(email != null){
                query = 'SELECT ID, Name, Title, Account.Name, Phone, Email, Owner.Name, FirstName, LastName, Is_Contact_Active__c, pi__score__c, pi__grade__c, pi__last_activity__c, pi__notes__c FROM Contact WHERE Is_Contact_Active__c = false AND ID !=: id AND ((Email =: email ) OR (FirstName =: fName AND LastName =: lName AND AccountID =: accId))';
                }
            else{
                query = 'SELECT ID, Name, Title, Account.Name, Phone, Email, Owner.Name, FirstName, LastName, Is_Contact_Active__c, pi__score__c, pi__grade__c, pi__last_activity__c, pi__notes__c FROM Contact WHERE Is_Contact_Active__c = false AND FirstName =: fName AND LastName =: lName AND AccountID =: accId';
                }
            duplicates = database.query(query);
                
            return duplicates;        
            }
    
    @AuraEnabled(cacheable=true)
    public static string checkRecord(ID id){
        string result;
        Contact con = new Contact();
        con = [SELECT ID, Has_Duplicate__c, Duplicate_is_Deactivated__c, Duplicate_Accepted__c FROM Contact WHERE ID =: id];
        if(con.Has_Duplicate__c == true && con.Duplicate_Is_Deactivated__c == false && con.Duplicate_Accepted__c == false){
            result = 'This record looks like a duplicate of existing record(s).  Please review to see if any would be worth using to take the place of this one.';
            }
        else if(con.Has_Duplicate__c == true && con.Duplicate_Is_Deactivated__c == true && con.Duplicate_Accepted__c == false){
            result = 'This record looks like a duplicate of existing record(s).  Please review to see if any would be worth using to take the place of this one.';
            }
        else{
            result = 'No duplicates or accepted duplicate.';
            }

        return result;
        }

    @AuraEnabled
    public static string checkRefresh(ID id){
        string result;
        Contact c = new Contact();
        c = [SELECT ID, CreatedDate, Refreshed__c FROM Contact WHERE ID =: ID];
        ID jobId = [SELECT Id, Name FROM ApexClass WHERE Name = 'ContactEntryDupCheckBatchable' LIMIT 1].ID;
        List<AsyncApexJob> runningJobs = [Select Id, Status, ApexClass.Name From AsyncApexJob WHERE CreatedDate = TODAY AND ApexClassId =: jobId];
        boolean proceed = true;
        for(AsyncApexJob aj: runningJobs){
            if(aj.Status != 'Completed'){
                proceed = false;
                }
            }
        if(proceed == false && c.Refreshed__c == false){
            result = 'Needs Refresh';
            }
        else{
            result = 'Proceed';
            }
        return result;
        }

    @AuraEnabled
    public static string deactivateContact(String id){
        Id deactivatedOwner;
        if(UserInfo.getOrganizationId() == '00Do0000000XqCh'){
            deactivatedOwner = [SELECT ID FROM User WHERE Username = 'salesforce.accounts@samtec.com' LIMIT 1].Id;
            }
        else{
            string userBox = 'salesforce.accounts@samtec.com.' + UserInfo.getUserName().substringAfterLast('.');
            deactivatedOwner = [SELECT ID FROM User WHERE Username =: userBox LIMIT 1].Id;
            }
        string result;
        Contact con = [SELECT ID, Is_Contact_Active__c, Owner.Id FROM Contact WHERE ID =: id];
        con.Is_Contact_Active__c = false;
        con.Owner.Id = deactivatedOwner;
        
        list<Opportunity> opps = new list<Opportunity>();
        for(Opportunity o: [SELECT ID, OwnerId, Previous_Owner__c FROM Opportunity WHERE ContactId =: con.id]){
            o.Previous_Owner__c = o.OwnerId;
            o.OwnerId = deactivatedOwner;
            opps.add(o);
            }
        
        list<ID> cdL = new list<ID>();
        for(ContentDocumentLink c : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: con.id]){
            cdL.add(c.ContentDocumentID);
            }
        
        list<ID> cd = new list<ID>();
        for(ContentDocument cdd: [SELECT ID, LatestPublishedVersionId FROM ContentDocument WHERE ID IN: cdL]){
            cd.add(cdd.LatestPublishedVersionId);
            }
        
        list<ContentVersion> version = new list<ContentVersion>();
        for(ContentVersion cv: [SELECT Id, OwnerId, Previous_Owner__c FROM ContentVersion WHERE Id IN: cd]){
            cv.Previous_Owner__c = cv.OwnerId;
            cv.OwnerId = deactivatedOwner;
            version.add(cv);
            }
        
        List<Case> cases = new list<Case>();
        for(Case cse: [SELECT ID, OwnerId, Previous_Owner__c FROM Case WHERE ContactId =: con.id]){
            cse.Previous_Owner__c = cse.OwnerId;
            cse.OwnerId = deactivatedOwner;
            cases.add(cse);
            }

        list<Product_Interest__c> pi = new List<Product_Interest__c>();
        for(Product_Interest__c p: [SELECT ID, OwnerId, Previous_Owner__c FROM Product_Interest__c WHERE Contact_Lookup_Relationship__c =:con.Id]){
            p.Previous_Owner__c = p.OwnerId;
            p.OwnerId = deactivatedOwner;
            pi.add(p);
            }

        list<Task> tasks = new list<Task>();
        for(Task t: [SELECT ID, OwnerId, Previous_Owner__c FROM Task WHERE WhoId =: con.Id]){
            t.Previous_Owner__c = t.OwnerId;
            t.OwnerId = deactivatedOwner;
            tasks.add(t);
            }

        list<Event> events = new list<Event>();
        for(Event e: [SELECT ID, OwnerId, Previous_Owner__c FROM Event WHERE WhoId =: con.Id]){
            e.Previous_Owner__c = e.OwnerId;
            e.OwnerId = deactivatedOwner;
            events.add(e);
            }

        try{
            update con;

            update events;
            update tasks;
            update pi;
            update cases;
            update version;
            update opps;

            result = 'Success';
            }
        catch(exception e){
            result = 'Error: ' + e.getMessage() + ' ' + e.getLineNumber();
            return result;
            }
            return result;
        }

    @AuraEnabled
    public static string deleteReplaceContact(String loseId, String winId){
        Id deactivatedOwner;
        string result = winId;

        Contact toDelete = [SELECT ID, Delete_Permitted__c FROM Contact WHERE ID =: loseId];
        toDelete.Delete_Permitted__c = true;
        update toDelete;
        delete toDelete;
        return result;
        }

    @AuraEnabled
    public static string entryAccepted(ID id){
        string result;
        Contact c = New Contact();
        c = [SELECT ID, Duplicate_Accepted__c, Duplicate_Accepted_By__c FROM Contact WHERE ID =: id];
        c.Duplicate_Accepted__c = true;
        c.Duplicate_Accepted_By__c = UserInfo.getUserId();
        update c;
        result = c.Id;
        return result;
        }

    @AuraEnabled
    public static string reactivateContact(String id){
        string result;
        Contact con = [SELECT ID, Is_Contact_Active__c, Owner.Id FROM Contact WHERE ID =: id];
        con.Is_Contact_Active__c = true;
        list<Opportunity> opps = new list<Opportunity>();
        for(Opportunity o: [SELECT ID, OwnerId, Previous_Owner__c FROM Opportunity WHERE ContactId =: con.id]){
            o.OwnerId = o.Previous_Owner__c;
            opps.add(o);
            }
        
        list<ID> cdL = new list<ID>();
        for(ContentDocumentLink c : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: con.id]){
            cdL.add(c.ContentDocumentID);
            }
        
        list<ID> cd = new list<ID>();
        for(ContentDocument cdd: [SELECT ID, LatestPublishedVersionId FROM ContentDocument WHERE ID IN: cdL]){
            cd.add(cdd.LatestPublishedVersionId);
            }
        
        list<ContentVersion> version = new list<ContentVersion>();
        for(ContentVersion cv: [SELECT Id, OwnerId, Previous_Owner__c FROM ContentVersion WHERE Id IN: cd]){
            cv.OwnerId = cv.Previous_Owner__c;
            version.add(cv);
            }
        
        List<Case> cases = new list<Case>();
        for(Case cse: [SELECT ID, OwnerId, Previous_Owner__c FROM Case WHERE ContactId =: con.id]){
            cse.OwnerId = cse.Previous_Owner__c;
            cases.add(cse);
            }

        list<Product_Interest__c> pi = new List<Product_Interest__c>();
        for(Product_Interest__c p: [SELECT ID, OwnerId, Previous_Owner__c FROM Product_Interest__c WHERE Contact_Lookup_Relationship__c =:con.Id]){
            p.OwnerId = p.Previous_Owner__c;
            pi.add(p);
            }

        list<Task> tasks = new list<Task>();
        for(Task t: [SELECT ID, OwnerId, Previous_Owner__c FROM Task WHERE WhoId =: con.Id]){
            t.OwnerId = t.Previous_Owner__c;
            tasks.add(t);
            }

        list<Event> events = new list<Event>();
        for(Event e: [SELECT ID, OwnerId, Previous_Owner__c FROM Event WHERE WhoId =: con.Id]){
            e.OwnerId = e.Previous_Owner__c;
            events.add(e);
            }

        try{
            update con;

            update events;
            update tasks;
            update pi;
            update cases;
            update version;
            update opps;
            
            result = 'Success';
            }
        catch(exception e){
            result = 'Error: ' + e.getMessage() + ' ' + e.getLineNumber();
            return result;
            }
            return result;
        }

    @AuraEnabled
    public static string reactivateDeleteContact(String loseId, string winId){
        string result;
        Contact toDelete = [SELECT ID From Contact WHERE ID =: loseId];
        Contact con = [SELECT ID, Is_Contact_Active__c, Owner.Id FROM Contact WHERE ID =: winId];
        con.Is_Contact_Active__c = true;
        list<Opportunity> opps = new list<Opportunity>();
        for(Opportunity o: [SELECT ID, OwnerId, Previous_Owner__c FROM Opportunity WHERE ContactId =: con.id]){
            o.OwnerId = o.Previous_Owner__c;
            opps.add(o);
            }
        
        list<ID> cdL = new list<ID>();
        for(ContentDocumentLink c : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: con.id]){
            cdL.add(c.ContentDocumentID);
            }
        
        list<ID> cd = new list<ID>();
        for(ContentDocument cdd: [SELECT ID, LatestPublishedVersionId FROM ContentDocument WHERE ID IN: cdL]){
            cd.add(cdd.LatestPublishedVersionId);
            }
        
        list<ContentVersion> version = new list<ContentVersion>();
        for(ContentVersion cv: [SELECT Id, OwnerId, Previous_Owner__c FROM ContentVersion WHERE Id IN: cd]){
            cv.OwnerId = cv.Previous_Owner__c;
            version.add(cv);
            }
        
        List<Case> cases = new list<Case>();
        for(Case cse: [SELECT ID, OwnerId, Previous_Owner__c FROM Case WHERE ContactId =: con.id]){
            cse.OwnerId = cse.Previous_Owner__c;
            cases.add(cse);
            }

        list<Product_Interest__c> pi = new List<Product_Interest__c>();
        for(Product_Interest__c p: [SELECT ID, OwnerId, Previous_Owner__c FROM Product_Interest__c WHERE Contact_Lookup_Relationship__c =:con.Id]){
            p.OwnerId = p.Previous_Owner__c;
            pi.add(p);
            }

        list<Task> tasks = new list<Task>();
        for(Task t: [SELECT ID, OwnerId, Previous_Owner__c FROM Task WHERE WhoId =: con.Id]){
            t.OwnerId = t.Previous_Owner__c;
            tasks.add(t);
            }

        list<Event> events = new list<Event>();
        for(Event e: [SELECT ID, OwnerId, Previous_Owner__c FROM Event WHERE WhoId =: con.Id]){
            e.OwnerId = e.Previous_Owner__c;
            events.add(e);
            }

        try{
            update con;

            update events;
            update tasks;
            update pi;
            update cases;
            update version;
            update opps;

            toDelete.Delete_Permitted__c = true;
            update toDelete;
            delete toDelete;
            
            result = winId;
            }
        catch(exception e){
            result = 'Error: ' + e.getMessage() + ' ' + e.getLineNumber();
            return result;
            }
            return result;
    }

}

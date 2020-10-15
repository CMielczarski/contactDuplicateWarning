@isTest
public class ContactEntryDuplicateCheckTest {
    
    public static testMethod void checkAndInsertDuplicatesTest(){
        Account acc = TestFactory.getAccount('Testing Account', true);
        
        Contact con = new Contact(FirstName = 'Test', 
                              LastName = 'Tester', 
                              Email = 'test@none.com', 
                              AccountId = acc.Id, 
                              Salutation = 'Mr', 
                              Title = 'CEO', 
                              Phone = '555-555-5555', 
                              Fax = '777-777-7777', 
                              Account_is_DENIED_PARTY__c = false, 
                              Denied_Party_Status__c = 'Cleared',
                              MailingStreet = '123 St',
                              MailingCity = 'New Albany',
                              MailingState = 'IN',
                              MailingPostalCode = '47150',
                              MailingCountry = 'USA',
                              Previous_Model_Downloads__c = null,
                              Previous_Sampled_Parts__c = null);
        
        Contact con2 = new Contact(FirstName = 'Test', 
                               LastName = 'Tester', 
                               Email = 'test@none.com', 
                               AccountId = acc.Id, 
                               Salutation = 'Mr', 
                               Title = 'CEO', 
                               Phone = '555-555-5555', 
                               Fax = '777-777-7777', 
                               Account_is_DENIED_PARTY__c = false, 
                               Denied_Party_Status__c = 'Cleared',
                               MailingStreet = '123 St',
                               MailingCity = 'New Albany',
                               MailingState = 'IN',
                               MailingPostalCode = '47150',
                               MailingCountry = 'USA',
                               Previous_Model_Downloads__c = null,
                               Previous_Sampled_Parts__c = null);

                               insert con;
                               insert con2;
        Test.startTest();
            ContactEntryDuplicateCheck.checkRecord(con2.Id);
            ContactEntryDuplicateCheck.checkRefresh(con2.Id);
            ContactEntryDuplicateCheck.getDuplicates(con2.Id);
            ContactEntryDuplicateCheck.entryAccepted(con2.Id);
        Test.stopTest();
    }

    public static testMethod void checkAndInsertDeactivatedDuplicatesTest(){
        Account acc = TestFactory.getAccount('Testing Account', true);
        acc.SGN_Location_ID__c = 55555;
        update acc;
        Contact con = new Contact(FirstName = 'Test', 
                              LastName = 'Tester', 
                              Email = 'test@none.com', 
                              AccountId = acc.Id, 
                              Salutation = 'Mr', 
                              Title = 'CEO', 
                              Phone = '555-555-5555', 
                              Fax = '777-777-7777', 
                              Account_is_DENIED_PARTY__c = false, 
                              Denied_Party_Status__c = 'Cleared',
                              MailingStreet = '123 St',
                              MailingCity = 'New Albany',
                              MailingState = 'IN',
                              MailingPostalCode = '47150',
                              MailingCountry = 'USA',
                              Previous_Model_Downloads__c = null,
                              Previous_Sampled_Parts__c = null);
        
        Contact con2 = new Contact(FirstName = 'Test', 
                               LastName = 'Tester', 
                               Email = 'test@none.com', 
                               AccountId = acc.Id, 
                               Salutation = 'Mr', 
                               Title = 'CEO', 
                               Phone = '555-555-5555', 
                               Fax = '777-777-7777', 
                               Account_is_DENIED_PARTY__c = false, 
                               Denied_Party_Status__c = 'Cleared',
                               MailingStreet = '123 St',
                               MailingCity = 'New Albany',
                               MailingState = 'IN',
                               MailingPostalCode = '47150',
                               MailingCountry = 'USA',
                               Previous_Model_Downloads__c = null,
                               Previous_Sampled_Parts__c = null);
            insert con;
            insert con2;

        Test.startTest();
            con.Is_Contact_Active__c = false;
            update con;                                        
            ContactEntryDuplicateCheck.getDeactivatedDuplicates(con2.Id);
            ContactEntryDuplicateCheck.reactivateContact(con.Id);
            Opportunity o = new Opportunity(Name = 'Test Opportunity', ContactID = con.Id, AccountID = acc.Id, StageName = 'Prospecting', CloseDate = system.today());
            insert o;
            ContentVersion cv = new ContentVersion(Title = 'Test',
            pathOnClient = 'Test.jpg', VersionData = blob.valueOf('Testing'));
            insert cv;
            ID document = [SELECT ID, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1].Id;
            ContentDocumentLink cdl2 = new ContentDocumentLink(ContentDocumentId = document, LinkedEntityId = con.Id, ShareType = 'I');
            insert cdl2;
            Case cse = New Case(ContactId = con.Id);
            insert cse;
            Product_Interest__c p = new Product_Interest__c(Contact_Lookup_Relationship__c = con.Id, Source__c = 'Website Order');
            insert p;
            Task t = new Task(WhoId = con.Id, Subject = 'Testing Task');
            insert t;
            Event e = new Event(whoId = con.Id, DurationInMinutes = 120, ActivityDateTime = system.now());
            insert e;

            ContactEntryDuplicateCheck.deactivateContact(con.Id);
            ContactEntryDuplicateCheck.reactivateContact(con.Id);
        Test.stopTest();
            ContactEntryDuplicateCheck.checkRecord(con2.Id);
            ContactEntryDuplicateCheck.deleteReplaceContact(con2.Id, con.Id);
        }


    public static testMethod void checkAndInsertDeactivatedDuplicatesTest2(){
            Account acc = TestFactory.getAccount('Testing Account', true);
            acc.SGN_Location_ID__c = 55555;
            update acc;
            Contact con = new Contact(FirstName = 'Test', 
                                  LastName = 'Tester', 
                                  Email = 'test@none.com', 
                                  AccountId = acc.Id, 
                                  Salutation = 'Mr', 
                                  Title = 'CEO', 
                                  Phone = '555-555-5555', 
                                  Fax = '777-777-7777', 
                                  Account_is_DENIED_PARTY__c = false, 
                                  Denied_Party_Status__c = 'Cleared',
                                  MailingStreet = '123 St',
                                  MailingCity = 'New Albany',
                                  MailingState = 'IN',
                                  MailingPostalCode = '47150',
                                  MailingCountry = 'USA',
                                  Previous_Model_Downloads__c = null,
                                  Previous_Sampled_Parts__c = null);
            
            Contact con2 = new Contact(FirstName = 'Test', 
                                   LastName = 'Tester', 
                                   Email = 'test@none.com', 
                                   AccountId = acc.Id, 
                                   Salutation = 'Mr', 
                                   Title = 'CEO', 
                                   Phone = '555-555-5555', 
                                   Fax = '777-777-7777', 
                                   Account_is_DENIED_PARTY__c = false, 
                                   Denied_Party_Status__c = 'Cleared',
                                   MailingStreet = '123 St',
                                   MailingCity = 'New Albany',
                                   MailingState = 'IN',
                                   MailingPostalCode = '47150',
                                   MailingCountry = 'USA',
                                   Previous_Model_Downloads__c = null,
                                   Previous_Sampled_Parts__c = null);
                insert con;
                insert con2;
    
            Test.startTest();
                con.Is_Contact_Active__c = false;
                update con;                                        
                ContactEntryDuplicateCheck.getDeactivatedDuplicates(con2.Id);
                ContactEntryDuplicateCheck.reactivateContact(con.Id);
                Opportunity o = new Opportunity(Name = 'Test Opportunity', ContactID = con.Id, AccountID = acc.Id, StageName = 'Prospecting', CloseDate = system.today());
                insert o;
                ContentVersion cv = new ContentVersion(Title = 'Test',
                pathOnClient = 'Test.jpg', VersionData = blob.valueOf('Testing'));
                insert cv;
                ID document = [SELECT ID, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1].Id;
                ContentDocumentLink cdl2 = new ContentDocumentLink(ContentDocumentId = document, LinkedEntityId = con.Id, ShareType = 'I');
                insert cdl2;
                Case cse = New Case(ContactId = con.Id);
                insert cse;
                Product_Interest__c p = new Product_Interest__c(Contact_Lookup_Relationship__c = con.Id, Source__c = 'Website Order');
                insert p;
                Task t = new Task(WhoId = con.Id, Subject = 'Testing Task');
                insert t;
                Event e = new Event(whoId = con.Id, DurationInMinutes = 120, ActivityDateTime = system.now());
                insert e;
            Test.stopTest();
            ContactEntryDuplicateCheck.deactivateContact(con.Id);
            ContactEntryDuplicateCheck.checkRecord(con2.Id);
            ContactEntryDuplicateCheck.reactivateDeleteContact(con2.Id, con.Id);
        }

}

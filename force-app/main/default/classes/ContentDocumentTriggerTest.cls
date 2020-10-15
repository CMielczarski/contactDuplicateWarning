@isTest
public class ContentDocumentTriggerTest {
    public static testMethod void checkFileInsert(){
        
        User u = new User(ProfileId = [SELECT Id FROM Profile WHERE Name =:'Standard Sales User'].Id,
                            LastName = 'last',
                            Email = 'testUser@testorg.com',
                            Username = 'testUser@SamtecTestorg.com',
                            CompanyName = 'Testing Co',
                            Title = 'Captian',
                            Alias = 'alias',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US'
                            );
        insert u;

        Account a = New Account(Name = 'Test Account', SGN_Location_ID__c = 5546);
        insert a;
        
        Opportunity o = new Opportunity(Name = 'Test Opp', CloseDate = system.today(), StageName = 'Formal Quote', Industry__c = 'Computer/Semiconductor', AccountId = a.Id);
        insert o;

        test.startTest();
            system.runAs(u){
                ContentVersion cv = new ContentVersion(Title = 'Test', PathOnClient = 'Test.Jpg', VersionData = Blob.ValueOf('TestContentData'));
                
                insert cv;
                ID Document = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1].Id;
                ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId = document, LinkedEntityId = o.Id, ShareType = 'I');
                insert cdl;
                }
        test.stopTest();
        }

    public static testMethod void checkNoteInsert(){
        
        User u = new User(ProfileId = [SELECT Id FROM Profile WHERE Name =:'Standard Sales User'].Id,
                            LastName = 'last',
                            Email = 'testUser@testorg.com',
                            Username = 'testUser@SamtecTestorg.com',
                            CompanyName = 'Testing Co',
                            Title = 'Captian',
                            Alias = 'alias',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US'
                            );
        insert u;
        Account a = New Account(Name = 'Test Account', SGN_Location_ID__c = 5546);
        insert a;
        
        Opportunity o = new Opportunity(Name = 'Test Opp', CloseDate = system.today(), StageName = 'Formal Quote', Industry__c = 'Computer/Semiconductor', AccountId = a.Id);
        insert o;

        test.startTest();
            system.runAs(u){
                ContentNote cn = new ContentNote(Title = 'test Note',
                                                 Content = Blob.valueOf('Test Content')
                                                 );
                insert cn ;   
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = o.Id;
                cdl.ContentDocumentId = cn.Id;
                cdl.shareType = 'V';
                insert cdl;
                }
        test.stopTest();
        }
}

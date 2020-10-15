@isTest
public class ChatterPostTriggerTest {
    
    public static testMethod void checkFeedItemInsert(){
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
                FeedItem fe = new FeedItem(ParentId = o.Id,
                                            Body = 'Test comment body');
                                            insert fe;

                }
        test.stopTest();
        }
}

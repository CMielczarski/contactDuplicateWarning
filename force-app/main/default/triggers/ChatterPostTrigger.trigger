trigger ChatterPostTrigger on FeedItem (after insert, after update){

    if(Trigger.isAfter){
        list<ID> pIds = new list<ID>();
        for(Profile p: [SELECT ID, Name FROM Profile WHERE (Name = 'System Administrator' OR Name = 'OM Integration' OR Name = 'COZYROC Integration')]){
            pIds.add(p.Id);
            }
        User u = [SELECT ID, Name, ProfileId FROM User WHERE ID =: UserInfo.getUserId()];
        if((Trigger.isInsert || Trigger.isUpdate) && !pIds.contains(u.ProfileId)){
            set<ID> cleanIDs = new set<ID>();
            for(FeedItem fi: Trigger.new){
                if(string.valueOf(fi.ParentId).startsWith('006')){
                    cleanIDs.add(fi.ParentId);
                    }
                }
            list<Opportunity> oppList = new list<Opportunity>();
            for(Opportunity o: [SELECT ID, Last_User_Modified_Date__c, Last_Updated_By__c FROM Opportunity WHERE ID IN: cleanIDs]){
                o.Last_User_Modified_Date__c = system.now();
                o.Last_Updated_By__c = u.Name;
                oppList.add(o);
                }
            update oppList;
            }
        }

}
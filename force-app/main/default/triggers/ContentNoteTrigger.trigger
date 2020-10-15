trigger ContentNoteTrigger on ContentDocument (after insert, after update){

    if(Trigger.isAfter){
        list<ID> pIds = new list<ID>();
        for(Profile p: [SELECT ID, Name FROM Profile WHERE (Name = 'System Administrator' OR Name = 'OM Integration' OR Name = 'COZYROC Integration')]){
            pIds.add(p.Id);
            }
        User u = [SELECT ID, Name, ProfileId FROM User WHERE ID =: UserInfo.getUserId()];
        if((Trigger.isInsert || Trigger.isUpdate) && !pIds.contains(u.ProfileId)){
            list<ID> idList = new list<ID>();
            list<ID> uniqueOppList = new list<ID>();
            for(ContentDocument cd: trigger.new){
                if(cd.PublishStatus != 'U'){
                    idList.add(cd.Id);
                    }
                }
                map<ID, boolean> mapOfContentVersion = new map<ID, boolean>();
                for(ContentVersion cv : [SELECT ID, ContentDocumentId, IsLatest FROM ContentVersion WHERE ContentDocumentId IN: idList AND isLatest = true]){
                    mapOfContentVersion.put(cv.ContentDocumentId, cv.IsLatest);
                    }
                    Set<ID> cleanIDs = new set<ID>();
                    Set<Id> newSet = mapOfContentVersion.keySet();
                    if(newSet.size() > 0){
                        for(ContentDocumentLink cdl: [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN: newSet]){
                            if(string.valueOf(cdl.LinkedEntityId).startsWith('006')){
                                if(!cleanIDs.contains(cdl.LinkedEntityId)){
                                    uniqueOppList.add(cdl.LinkedEntityId);
                                    cleanIDs.add(cdl.LinkedEntityId);
                                    }
                                }
                            }
                        }
                
            list<Opportunity> oppList = new list<Opportunity>();
            for(Opportunity o: [SELECT ID, Last_User_Modified_Date__c, Last_Updated_By__c FROM Opportunity WHERE ID IN: uniqueOppList]){
                o.Last_User_Modified_Date__c = system.now();
                o.Last_Updated_By__c = u.Name;
                oppList.add(o);
                }
            update oppList;
            }
        }

}
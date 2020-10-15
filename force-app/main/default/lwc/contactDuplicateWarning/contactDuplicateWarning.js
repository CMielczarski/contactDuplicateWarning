import { LightningElement, api, track } from 'lwc';

import getDuplicates from '@salesforce/apex/ContactEntryDuplicateCheck.getDuplicates';
import getDeactivatedDuplicates from '@salesforce/apex/ContactEntryDuplicateCheck.getDeactivatedDuplicates';
import reactivateDeleteContact from '@salesforce/apex/ContactEntryDuplicateCheck.reactivateDeleteContact';
import deleteReplaceContact from '@salesforce/apex/ContactEntryDuplicateCheck.deleteReplaceContact';
import checkRecord from '@salesforce/apex/ContactEntryDuplicateCheck.checkRecord';
import checkRefresh from '@salesforce/apex/ContactEntryDuplicateCheck.checkRefresh';
import entryAccepted from '@salesforce/apex/ContactEntryDuplicateCheck.entryAccepted'; 

export default class ContactDuplicateWarning extends LightningElement {

@api recordId;
showPopup = false;
showWarning = false;
warningMessage;
showTab = false;
showWarningTab = false;
navTab = false;
warningTab = false;
duplicates = [];
deactivatedDuplicates = [];
spinner = false;
proceed = false;
showOptions = false;
deacDupCount = 'Reactivate one of these formerly active records? ';
regDupCount = 'Use one of these current, active records? ';
viewRecordId;
showItem = false;
/*fields = ['Name', 
          Phone, 
          Account.Name, 
          Mobile, 
          iSell__Avention_ID__c, 
          Fax, 
          DNBoptimizer__DnBContactRecord__c, 
          Owner.Name, 
          Email, 
          SGN_Contact_ID__c, 
          Title, 
          ReportsToId.Name, 
          Business_Unit__c, 
          eCAD_Model_Format_Preference__c,
          ERP_Preference__c,
          mCAD_Model_Format_Preference__c,
          SI_Software_Preference__c];*/

@track box = 'box-show';
    
    connectedCallback(){
        console.log('Still Have Record ID?: ' + this.recordId);
        this.proceed = false;
        this.spinner = true;
        console.log('Checking refresh');
        checkRefresh({
                    "id" : this.recordId
                    })
                .then(
                    result =>{
                        console.log('Refresh Check result: ' + result);
                        if(result === 'Needs Refresh'){
                            this.proceed = false;
                            this.extraRefresh();
                            }
                        else if(result.includes('Proceed')){
                            this.proceed = true;
                                }
                        console.log('Proceed?: ' + this.proceed);
                        if(this.proceed === true){
                            this.recordCheck();
                                        }
                        }
                    )
                .catch(
                    error=>{
                        console.log('Refresh check error: ' + error.message);
                        this.spinner = false;
                        }
                    );
        }

    extraRefresh(){
            checkRefresh({
                        "id" : this.recordId
                        })
                .then(
                    result =>{
                            console.log('Refresh Check result: ' + result);
                            if(result === 'Needs Refresh'){
                                console.log('Still waiting...');
                                this.extraRefresh();
                                this.proceed = false;
                                }
                            else if(result.includes('Proceed')){
                                this.proceed = true;
                                this.recordCheck();
                                console.log('Proceeding');
                                }
                            }
                    )
                .catch(
                    error=>{
                        console.log('Extra refresh error: ' + error.message);
                        this.spinner = false;
                        }
                    );
        }

    recordCheck(){
        checkRecord({
            "id" : this.recordId
             })
             .then(
                   result=>{
                        this.warningMessage = result;
                        console.log('Result: ' + result);
                        var readRslt = result;
                        console.log('Dup Check Result: ' + readRslt);
                        if(readRslt.includes('existing record(s)')){
                            console.log('Not a deactivated Dupe');
                            this.showPopup = true;
                            this.showWarning = true;
                            this.showTab = true;
                            this.showWarningTab = false;
                            this.warningMessage = result;
                            }
                        else if(readRslt.includes('accepted duplicate')){
                            this.showPopup = false;
                            this.showWarning = false;
                            this.showTab = false;
                            this.showWarningTab = false;
                            }
                            console.log('Show Warning?: ' + this.showWarning);
                            this.spinner = false;
                        }
                        )
                    .catch(
                        error=>{
                            console.log('Check record Error: ' + error.message);
                            this.spinner = false;
                            }
                    );
        }
    
    reactivateReplaceItem(event){
        this.spinner = true;
        var itemId = event.target.title;
        reactivateDeleteContact({'winId' : itemId,
                                 'loseId' : this.recordId})
            .then(
                result=>{
                    this.spinner = false;
                    var newUrl = '/lightning/r/Contact/' + result + '/view';
                    window.location.replace(newUrl);
                    }
                )
            .catch(
                error=>{
                    this.spinner = false;
                    console.log('Reactivate error: ' + error.message);
                    }
                );
        }

    acceptEntry(){
        this.spinner = true;
        entryAccepted({
                        "id" : this.recordId
                        })
                .then(
                    result=>{
                        this.spinner = false;
                        var newUrl = '/lightning/r/Contact/' + result + '/view';
                        window.location.replace(newUrl);
                        }
                    )
                .catch(
                    error=>{
                        console.log('Accept Error: ' + error.message);
                        }
                    );
        }

    deleteReplaceItem(event){
        this.spinner = true;
        var itemId = event.target.title;
        deleteReplaceContact({'winId' : itemId,
                              'loseId' : this.recordId})
            .then(
                result=>{
                    this.spinner = false;
                    var newUrl = '/lightning/r/Contact/' + result + '/view';
                    window.location.replace(newUrl);
                    }
                )
            .catch(
                error=>{
                    this.spinner = false;
                    console.log('Replace error: ' + error.message);
                    }
                );
            }
            
    openTab(event){
        this.showWarning = false;
        this.showOptions = true;
        event.preventDefault();
        getDuplicates({
                        "id": this.recordId
                       })
            .then(
                result=>{
                    this.duplicates = result;
                    if(this.duplicates.length > 0){
                        this.navTab = true;
                        this.regDupCount = this.regDupCount + '(' + this.duplicates.length + ')';
                        }
                    }
                )
            .catch(
                error=>{
                        console.log('Open Tab Error: ' + error.message);
                    }
                );
                
        getDeactivatedDuplicates({
                                "id": this.recordId
                                })
            .then(
                result=>{
                    this.deactivatedDuplicates = result;
                    if(this.deactivatedDuplicates.length > 0){
                        this.warningTab = true;
                        this.deacDupCount = this.deacDupCount + '(' + this.deactivatedDuplicates.length + ')';
                        }
                    }
                )
            .catch(
                error=>{
                    console.log('Open Warning Error: ' + error.message);
                    }
                );
        }
        
    cancelRemove(){
        this.spinner = true;
        var itemId = '000000000000000000';
        deleteReplaceContact({'winId' : itemId,
                              'loseId' : this.recordId})
            .then(
                result=>{
                        this.spinner = false;
                        console.log(result);
                        var newUrl = '/lightning/o/Contact/home';
                        window.location.replace(newUrl);
                        }
                    )
            .catch(
                error=>{
                    this.spinner = false;
                    console.log('Replace error: ' + error.message);
                    }
                );
        }

    openItem(event){
        event.preventDefault();
        var id = event.target.value;
        var url = '/' + id;
        window.open(url);
        }

    openItemAlt(event){
        event.preventDefault();
        var id = event.target.value;
        this.viewRecordId = id;
        this.showItem = true;
        this.box = 'box-hide';
        }

    closeItemAlt(){
        this.showItem = false;
        this.box = 'box-show';
        }

}
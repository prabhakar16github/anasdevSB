import { LightningElement,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDataOnLoad from '@salesforce/apex/BigObjectDataViewerController.getDataOnLoad';
import getRecordsFromApex from '@salesforce/apex/BigObjectDataViewerController.getRecordsFromApex';

export default class BigObjectDataViewer extends LightningElement {
    showSpinner = false;
    possibleObjects = [];
    selectedObject = '';
    selectedFromCreatedDate = '';
    selectedToCreatedDate = '';
    disabledButton = false;
    columnNames = [];
    data = [];
    showData = false;
    totalCountOfRecords = '';
    allData = [];
    currentPageNumber = 1;
    pageSize = 20;
    totalPages = 0;
    pageList = [];
    firstButton = false;
    lastButton = false;
    
    connectedCallback() {
        this.showSpinner = true;
        getDataOnLoad()
        .then(result => {
            if(result.message.includes('SUCCESS')) {
                this.showSpinner = false;
                this.possibleObjects = JSON.parse(result.possibleObjects);
            }
            else {
                this.showSpinner = false;
                this.showToast('ERROR','error',result.message);
            }
        })
        .catch(error => {
            this.showSpinner = false;
            this.showToast('ERROR','error',error);
        })
    }

    showToast(title,variant,message) {
        const event = new ShowToastEvent({
            title : title,
            message : message,
            variant : variant
        });
        this.dispatchEvent(event);
    }

    handleObjectChange(event) {
        this.selectedObject = event.detail.value;
    }

    handleChangeFromDate(event) {
        this.selectedFromCreatedDate = event.detail.value;
    }

    handleChangeToDate(event) {
        this.selectedToCreatedDate = event.detail.value;
    }

    getRecords(event) {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });  
        if(isValid) {
            this.disableButton = true;
            this.showSpinner = true;
            getRecordsFromApex({selectedObject : this.selectedObject,selectedFromCreatedDate : this.selectedFromCreatedDate,selectedToCreatedDate : this.selectedToCreatedDate})
            .then(result =>{
            if(result.message.includes('SUCCESS')) {
                this.columnNames = JSON.parse(result.columnNames);
                this.allData = result.listData;
                this.disableButton = false;
                this.showSpinner = false; 
                if(this.allData.length > 0) {
                    this.showData = true;
                    this.totalPages = Math.ceil(this.allData.length/this.pageSize);
                    this.currentPageNumber = 1;
                    this.totalCountOfRecords = 'Total Number of Records: '+this.allData.length+'  -  '+'Total Pages: '+this.totalPages;
                    this.buildData();
                }   
                else {
                    this.showData = false;
                    this.showToast('INFO','info','No Records Found. Change filters to view the data')
                }
            }
            else {
                this.disableButton = false;
                this.showSpinner = false;
                this.showToast('ERROR','error',result.message);
            }
        })
        .catch(error =>{
            this.disableButton = false;
            this.showSpinner = false;
            this.showToast('ERROR','error',error);
        })
        }
    }

    buildData() {
        var data = [];
        var pageNumber = this.currentPageNumber;
        var pageSize = this.pageSize;
        var allData = this.allData;
        var x = (pageNumber-1)*pageSize;
        for(;x<=(pageNumber)*pageSize; x++) {
            if(allData[x]) {
                data.push(allData[x]);
            }
        }
        this.data = data;
        this.generatePageList(pageNumber);
    }

    generatePageList(pageNumber) {
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = this.totalPages;
        if(totalPages > 1){
            if(totalPages <= 10){
                var counter = 2;
                for(; counter < (totalPages); counter++){
                    pageList.push(counter);
                } 
            } else{
                if(pageNumber < 5){
                    pageList.push(2, 3, 4, 5, 6);
                } else{
                    if(pageNumber>(totalPages-5)){
                        pageList.push(totalPages-5, totalPages-4, totalPages-3, totalPages-2, totalPages-1);
                    } else{
                        pageList.push(pageNumber-2, pageNumber-1, pageNumber, pageNumber+1, pageNumber+2);
                    }
                }
            }
        }
        this.pageList = pageList;
        this.firstButtonDisabled();
        this.lastButtonDisabled();
    }

    onNext() {        
        var pageNumber = this.currentPageNumber;
        this.currentPageNumber = pageNumber+1;
        this.buildData();
    }
    
    onPrev() {        
        var pageNumber = this.currentPageNumber;
        this.currentPageNumber =  pageNumber-1;
        this.buildData();
    }
    
    onFirst(){        
        this.currentPageNumber = 1;
        this.buildData();
    }
    
    onLast(){   
        this.currentPageNumber = this.totalPages;
        this.buildData();
    }

    firstButtonDisabled() {
        if(this.currentPageNumber == 1) {
            this.firstButton = true;
        }
        else {
            this.firstButton = false;
        }
    }

    lastButtonDisabled() {
        if(this.currentPageNumber == this.totalPages)  {
            this.lastButton = true;
        }  
        else {
            this.lastButton = false;
        }
    }

    downloadCSVFile(event) {
        let rowEnd = '\n';
        let csvString = '';
        let rowData = new Set();
        this.allData.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });

        rowData = Array.from(rowData);
        csvString += rowData.join(',');
        csvString += rowEnd;

        for(let i=0; i < this.allData.length; i++){
            let colValue = 0;
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    let rowKey = rowData[key];
                    if(colValue > 0){
                        csvString += ',';
                    }
                    let value = this.allData[i][rowKey] === undefined ? '' : this.allData[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }
        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvString);
        downloadElement.target = '_self';
        downloadElement.download = this.selectedObject+'-'+this.selectedFromCreatedDate+'-'+this.selectedToCreatedDate+'.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        downloadElement.click(); 
    }
}
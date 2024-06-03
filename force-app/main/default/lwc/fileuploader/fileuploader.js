import { LightningElement } from 'lwc';
import { track, wire,api } from 'lwc';
import AttachmentIcon from '@salesforce/resourceUrl/AttachmentIcon';
import saveFiles from '@salesforce/apex/FileUploaderClass.saveFiles';
import getFiles from '@salesforce/apex/FileUploaderClass.returnFiles';

export default class Fileuploader extends LightningElement {
    showLoadingSpinner = false;
    @track fileNames = '';
    @track filesUploaded = [];
    @track dataFileName;
    @track columns;

    AttIcon = AttachmentIcon;


    handleFileChanges(event) {
        let files = event.target.files;

        if (files.length > 0) {
            let filesName = '';
            console.log('enter files');
            for (let i = 0; i < files.length; i++) {
                let file = files[i];

                filesName = filesName + file.name + ',';

                let freader = new FileReader();
                freader.onload = f => {
                    let base64 = 'base64,';
                    let content = freader.result.indexOf(base64) + base64.length;
                    let fileContents = freader.result.substring(content);
                    this.filesUploaded.push({
                        Title: file.name,
                        VersionData: fileContents
                    });
                };
                freader.readAsDataURL(file);
            }

            this.fileNames = filesName.slice(0, -1);
        }
    }

    handleSaveFiles() {
        this.showLoadingSpinner = true;
        saveFiles({filesToInsert: this.filesUploaded})
        .then(data => {
            this.showLoadingSpinner = false;
            console.log('uploaded successfully');
            this.getFilesData(data);
            console.log('data=='+data);
            this.fileNames = undefined;
        })
        .catch(error => {
            console.log('error=='+JSON.stringify(error));
        });
    }

    getFilesData(lstIds) {
        getFiles({lstFileIds: lstIds})
        .then(data => {
            data.forEach((record) => {
                record.FileName = '/' + record.Id;
            });

            this.dataFileName = data;
        })
        .catch(error => {
            window.console.log('error ====> ' + error);
        })
    }

}
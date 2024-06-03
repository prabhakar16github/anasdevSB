import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import submitReview from '@salesforce/apex/KnowledgeArticleReviewController.submitReview';

export default class KnowledgeArticleReview extends LightningElement {
    @api recordId;
    rating = '';
    review = '';
    showForm = true;
    get ratingOptions() {
        return [
            { label: '1', value: '1' },
            { label: '2', value: '2' },
            { label: '3', value: '3' },
            { label: '4', value: '4' },
            { label: '5', value: '5' },
        ];
    }

    get disableSubmit() {
        return (this.rating == '' || this.review == '');
    }

    handleRatingChange(event) {
        this.rating = event.target.value;
    }

    handleReviewChange(event) {
        this.review = event.target.value;
    }

    handleSubmit() {
        submitReview({knowledgeId:this.recordId , rating:this.rating, review:this.review})
            .then(result => {
                if(result == 'success') {
                    const evt = new ShowToastEvent({
                        title: "Thanks!",
                        message: "Review Submitted Successfully",
                        variant: "success",
                    });
                    this.dispatchEvent(evt);

                    this.rating = '';
                    this.review = '';
                    this.showForm = false;
                } else {
                    console.log(result);
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: "An error has occured!",
                        variant: "error",
                    });
                    this.dispatchEvent(evt);
                }
            })
            .catch(error => {
                console.log(error);
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: "An error has occured!",
                    variant: "error",
                });
                this.dispatchEvent(evt);
            });
    }
}
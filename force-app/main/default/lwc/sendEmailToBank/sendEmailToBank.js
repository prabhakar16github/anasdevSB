import { LightningElement, wire } from 'lwc';
import sendEmail from '@salesforce/apex/EmailController.sendEmail';

export default class CustomEmail extends LightningElement {
  errorMessage = '';

  handleSubmit(event) {
    event.preventDefault();
    const formData = new FormData(event.target);
    const recipient = formData.get('to');
    const subject = formData.get('subject');
    const body = formData.get('body');
    const attachment = formData.get('attachment');

    sendEmail({ recipient, subject, body, attachment })
      .then(result => {
        console.log(result);
        alert('Email sent successfully');
      })
      .catch(error => {
        console.error(error);
        this.errorMessage = error.body.message;
      });
  }
}
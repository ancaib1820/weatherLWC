import { LightningElement, api, wire, track } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getWeatherInfo from '@salesforce/apex/WeatherController.getWeatherInfo';
import updateAccountAddress from '@salesforce/apex/WeatherController.updateBillingAddress';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class WeatherComponent extends LightningElement {
    @api recordId;
    temperature;
    description;
    iconUrl;
    errorMessage;
    isLoading = true;
     street='';
     city='';
     state='';
     postalCode='';
     country='';

    handleStreetChange(event) {
        this.street = event.target.value;
    }

    handleCityChange(event) {
        this.city = event.target.value;
    }

    handleStateChange(event) {
        this.state = event.target.value;
    }

    handlePostalCodeChange(event) {
        this.postalCode = event.target.value;
    }

    handleCountryChange(event) {
        this.country = event.target.value;
    }

    


    @wire(getWeatherInfo, { accountId: '$recordId' })
    wiredWeatherInfo({ error, data }) {
        if (data) {
            this.temperature = data.temperature;
            this.description = data.description;
            this.iconUrl = data.iconUrl;
            console.log(this.iconUrl);
            this.isLoading = false;
        } else if (error) {
            this.errorMessage = error.body.message;
            this.isLoading = false;
        }
    }

    handleSave() {

updateAccountAddress({accid: this.recordId,cityparam: this.city, streetparam:this.street, stateparam: this.street, postalCodeparam: this.postalCode, countryparam: this.country })
          .then(() => {
            this.dispatchEvent(
              new ShowToastEvent({
                title: 'Success',
                message: 'Account address updated',
                variant: 'success',
              }),
            );

        this.handleReset();
        this.updateRecordView(this.recordId);
        })
        .catch(error => {
          console.error(error);
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error',
              message: error.body.message,
              variant: 'error',
            }),
          );
        });
    }

    handleReset() {
        this.street = '';
        this.city = '';
        this.state = '';
        this.postalCode = '';
        this.country = '';
      }
      updateRecordView(recordId) {
        updateRecord({ fields: { Id: recordId } })
        .then(() => {
           // getRecordNotifyChange([{recordId: this.recordId}]);
           return refreshApex(this.wiredWeatherInfo);
        })
        .catch(error => {
            console.error(error);
        });
    }
}

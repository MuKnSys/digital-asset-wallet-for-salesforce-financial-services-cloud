import { LightningElement, track } from 'lwc';
import { labels } from './labels';
import { BUTTON_VARIANT, ICONS, SPINNER_SIZE } from 'c/constants';
import updateAllViaLwc from '@salesforce/apex/SecuritiesPricingService.updateAllViaLwc';

export default class GetMarketValues extends LightningElement {
    labels = labels;
    buttonVariants = BUTTON_VARIANT;
    icons = ICONS;
    spinnerSize = SPINNER_SIZE;

    @track isLoading = true;
    @track isSuccess = false;
    @track errorMessage = '';
    @track successMessage = '';

    connectedCallback() {
        this.isLoading = true;
        updateAllViaLwc()
            .then(result => {
                this.isSuccess = true;
                this.successMessage = result;
                this.isLoading = false;
            })
            .catch(error => {
                this.isSuccess = false;
                this.errorMessage = error && error.body && error.body.message ? error.body.message : this.labels.ERROR_TEXT;
                this.isLoading = false;
            });
    }

    handleClose() {
        if (typeof this.close === 'function') {
            this.close();
        } else {
            this.dispatchEvent(new CustomEvent('close'));
        }
    }
} 
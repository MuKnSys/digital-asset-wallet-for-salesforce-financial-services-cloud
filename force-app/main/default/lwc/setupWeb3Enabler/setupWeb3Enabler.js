import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { labels } from './labels';
import { TOAST_VARIANT, TOAST_MODE, STEPS } from 'c/constants';

import getSetup from '@salesforce/apex/DigitalAssetWalletSetup.getSetup';

export default class SetupWeb3Enabler extends LightningElement {
    isLoading = true;
    labels = labels;
    steps = STEPS;

    @track
    setupData = {};

    @track
    authorizationStatus = {};

    get activeSections() {
        return [this.steps.n1, this.steps.n2];
    }

    get isOrgAuthorized() {
        return this.setupData.orgAuthorized;
    }

    get isOrgNotAuthorized() {
        return !this.setupData.orgAuthorized;
    }

    get authroizeEndpoint() {
        return this.setupData.muknCaSFDCAppUrl + '/install?orgId=' + this.setupData.orgId;
    }

    get reAuthroizeEndpoint() {
        return this.setupData.muknCaSFDCAppUrl + '/reauthorize?orgId=' + this.setupData.orgId;
    }

    get verifyAuthorizeEndpoint() {
        return this.setupData.muknCaSFDCAppUrl + '/authorized/' + this.setupData.orgId;
    }

    async loadSetup() {
        this.setupData = await getSetup();
        this.authorizationStatus = this.setupData.authorizationStatus;
    }

    async handleRefresh() {
        this.isLoading = true;
        try {
            await this.loadSetup();
        } catch (error) {
            const erroMessage = error.body ? error.body.message : error.message;
            this.showToast(erroMessage);
        } finally {
            this.isLoading = false;
        }
    }

    async connectedCallback() {
        try {
            await this.loadSetup();
        } catch (error) {
            const erroMessage = error.body ? error.body.message : error.message;
            this.showToast(erroMessage);
        } finally {
            this.isLoading = false;
        }
    }

    showToast(title, message, type = TOAST_VARIANT.ERROR, mode = TOAST_MODE.ERROR) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: type,
                mode: mode
            })
        );
    }
}

import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { TOAST_VARIANT, TOAST_MODE, STEPS } from 'c/constants';
import getSetup from '@salesforce/apex/DigitalAssetWalletSetup.getSetup';

export default class SetupDigitalAssetWallet extends LightningElement {
    @track isLoading = true; // Use @track for reactivity
    @track steps = STEPS || { n1: 'OrgInfo', n2: 'AuthActions' }; // Fallback for STEPS
    @track setupData = {}; // Initial empty object
    @track authorizationStatus = {};

    get activeSections() {
        return [this.steps?.n1 || 'OrgInfo', this.steps?.n2 || 'AuthActions'];
    }

    get isOrgAuthorized() {
        return this.setupData?.orgAuthorized || false;
    }

    get isOrgNotAuthorized() {
        return !this.isOrgAuthorized;
    }

    get authroizeEndpoint() {
        return this.setupData?.muknCaSFDCAppUrl && this.setupData?.orgId
            ? `${this.setupData.muknCaSFDCAppUrl}/install?orgId=${this.setupData.orgId}`
            : '';
    }

    get reAuthroizeEndpoint() {
        return this.setupData?.muknCaSFDCAppUrl && this.setupData?.orgId
            ? `${this.setupData.muknCaSFDCAppUrl}/reauthorize?orgId=${this.setupData.orgId}`
            : '';
    }

    get verifyAuthorizeEndpoint() {
        return this.setupData?.muknCaSFDCAppUrl && this.setupData?.orgId
            ? `${this.setupData.muknCaSFDCAppUrl}/authorized/${this.setupData.orgId}`
            : '';
    }

    async loadSetup() {
        try {
            console.log('Calling getSetup...');
            const result = await getSetup();
            console.log('getSetup result:', result);
            this.setupData = result || {}; // Fallback to empty object if null
            this.authorizationStatus = this.setupData?.authorizationStatus || {};
        } catch (error) {
            console.error('Error in loadSetup:', error);
            this.setupData = {}; // Reset to empty object on error
            this.authorizationStatus = {};
            throw error;
        }
    }

    async handleRefresh() {
        this.isLoading = true;
        try {
            await this.loadSetup();
        } catch (error) {
            const errorMessage = error.body?.message || error.message || 'Unknown error';
            this.showToast('Error Refreshing Data', errorMessage);
        } finally {
            this.isLoading = false;
        }
    }

    async connectedCallback() {
        try {
            await this.loadSetup();
        } catch (error) {
            const errorMessage = error.body?.message || error.message || 'Unknown error';
            this.showToast('Error Loading Data', errorMessage);
        } finally {
            this.isLoading = false;
        }
    }

    showToast(title, message, variant = TOAST_VARIANT.ERROR, mode = TOAST_MODE.DISMISSABLE) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant,
                mode
            })
        );
    }
}
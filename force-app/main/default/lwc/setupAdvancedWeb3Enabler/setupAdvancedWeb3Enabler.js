import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { labels } from './labels';
import { TOAST_VARIANT, TOAST_MODE, STEPS } from 'c/constants';

import getSetup from '@salesforce/apex/DigitalAssetWalletAdvancedSetup.getSetup';
import saveCoinGeckoCredentials from '@salesforce/apex/DigitalAssetWalletAdvancedSetup.saveCoinGeckoCredentials';
import deleteCoinGeckoCredentials from '@salesforce/apex/DigitalAssetWalletAdvancedSetup.deleteCoinGeckoCredentials';
import reinitializeAssetToken from '@salesforce/apex/DigitalAssetWalletAdvancedSetup.reinitializeAssetToken';
import reinitializeContractToken from '@salesforce/apex/DigitalAssetWalletAdvancedSetup.reinitializeContractToken';

export default class SetupAdvancedWeb3Enabler extends LightningElement {
    isLoading = true;
    labels = labels;
    steps = STEPS;

    links = {
        coinGeckoLink: 'https://www.coingecko.com/en/api/pricing'
    };

    dataChanged = {
        coinGecko: false
    };

    @track
    setupData = {};

    get activeSections() {
        return [this.steps.n1, this.steps.n2];
    }

    async loadSetup() {
        this.setupData = await getSetup();
    }

    handleCoinGeckoApiKey(event) {
        this.setupData.coinGeckoAPIKey = event.detail.value;
        this.dataChanged.coinGecko = true;
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

    async handleReinitializeAssetToken() {
        this.isLoading = true;
        try {
            await reinitializeAssetToken();
            this.showToast(
                this.labels.ATCT.ReinitializeSuccess,
                this.labels.ATCT.ReinitializeATInfo,
                TOAST_VARIANT.SUCCESS,
                TOAST_MODE.SUCCESS
            );
        } catch (error) {
            const erroMessage = error.body ? error.body.message : error.message;
            this.showToast(erroMessage);
        } finally {
            this.isLoading = false;
        }
    }

    async handleReinitializeContractToken() {
        this.isLoading = true;
        try {
            await reinitializeContractToken();
            this.showToast(
                this.labels.ATCT.ReinitializeSuccess,
                this.labels.ATCT.ReinitializeCTInfo,
                TOAST_VARIANT.SUCCESS,
                TOAST_MODE.SUCCESS
            );
        } catch (error) {
            const erroMessage = error.body ? error.body.message : error.message;
            this.showToast(erroMessage);
        } finally {
            this.isLoading = false;
        }
    }

    async handleCoinGeckoApiKeySave() {
        if (!this.dataChanged.coinGecko) {
            return;
        }

        this.isLoading = true;
        try {
            await saveCoinGeckoCredentials({ coinGeckoAPIKey: this.setupData.coinGeckoAPIKey });
            await this.loadSetup();
        } catch (error) {
            const erroMessage = error.body ? error.body.message : error.message;
            this.showToast(erroMessage);
        } finally {
            this.dataChanged.coinGecko = false;
            this.isLoading = false;
        }
    }

    async handleCoinGeckoApiKeyDelete() {
        if (this.setupData.coinGeckoAPIKey == null) {
            return;
        }

        this.isLoading = true;
        try {
            await deleteCoinGeckoCredentials();
            await this.loadSetup();
        } catch (error) {
            const erroMessage = error.body ? error.body.message : error.message;
            this.showToast(erroMessage);
        } finally {
            this.dataChanged.coinGecko = false;
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
import SetupHeader2 from '@salesforce/label/c.SetupHeader2';
import SetupHeader2Text from '@salesforce/label/c.SetupHeader2Text';
import SetupContainer from '@salesforce/label/c.SetupContainer';

import AssetTokenContractTokenHeader from '@salesforce/label/c.AssetTokenContractTokenHeader';
import AssetTokenContractTokenTitle from '@salesforce/label/c.AssetTokenContractTokenTitle';
import AssetTokenContractTokenInfo from '@salesforce/label/c.AssetTokenContractTokenInfo';
import AssetTokenContractTokenReinitializeAT from '@salesforce/label/c.AssetTokenContractTokenReinitializeAT';
import AssetTokenContractTokenReinitializeCT from '@salesforce/label/c.AssetTokenContractTokenReinitializeCT';
import AssetTokenContractTokenReinitializeSuccess from '@salesforce/label/c.AssetTokenContractTokenReinitializeSuccess';
const AssetTokenContractTokenReinitializeATInfo = 'Investment Assets Reinitialized.';
import AssetTokenContractTokenReinitializeCTInfo from '@salesforce/label/c.AssetTokenContractTokenReinitializeCTInfo';

import SetupCoinGeckoHeader from '@salesforce/label/c.SetupCoinGeckoHeader';
import SetupCoinGeckoTitle from '@salesforce/label/c.SetupCoinGeckoTitle';
import SetupCoinGeckoInfo from '@salesforce/label/c.SetupCoinGeckoInfo';
import SetupCoinGeckoLink from '@salesforce/label/c.SetupCoinGeckoLink';
import SetupCoinGeckoInput from '@salesforce/label/c.SetupCoinGeckoInput';
import SetupCoinGeckoSave from '@salesforce/label/c.SetupCoinGeckoSave';
import SetupCoinGeckoRemove from '@salesforce/label/c.SetupCoinGeckoRemove';

export const labels = {
    Header2: SetupHeader2,
    Header2Text: SetupHeader2Text,
    Container: SetupContainer,
    ATCT: {
        Header: AssetTokenContractTokenHeader,
        Title: AssetTokenContractTokenTitle,
        Info: AssetTokenContractTokenInfo,
        ReinitializeAT: AssetTokenContractTokenReinitializeAT,
        ReinitializeCT: AssetTokenContractTokenReinitializeCT,
        ReinitializeSuccess: AssetTokenContractTokenReinitializeSuccess,
        ReinitializeATInfo: AssetTokenContractTokenReinitializeATInfo,
        ReinitializeCTInfo: AssetTokenContractTokenReinitializeCTInfo
    },
    CoinGecko: {
        Header: SetupCoinGeckoHeader,
        Title: SetupCoinGeckoTitle,
        Info: SetupCoinGeckoInfo,
        Link: SetupCoinGeckoLink,
        Input: SetupCoinGeckoInput,
        Save: SetupCoinGeckoSave,
        Remove: SetupCoinGeckoRemove
    }
}; 
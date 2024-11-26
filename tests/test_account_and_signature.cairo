


use super::utils::{gen_public_key,account_contract,sign_invalid_transaction,NUTRON_WALLET_ADDRESS,TX_HASH,sign_valid_transaction};
use nutron_wallet_contract::account::{IAccountDispatcherTrait};

use snforge_std::signature::{
    stark_curve::{StarkCurveKeyPairImpl, StarkCurveSignerImpl, StarkCurveVerifierImpl},
};
use starknet::ContractAddress;







#[test]
fn test_public_key(){
   let (account,_) =account_contract();
  assert_eq!(account.public_key(), gen_public_key());
}
#[test]
fn test_contract_address(){
    let (_,account) =account_contract();
    let ntron_address:ContractAddress= NUTRON_WALLET_ADDRESS.try_into().unwrap();
    assert_eq!(account, ntron_address);
}

#[test]
fn test_valid_signature(){
    let (account,_) =account_contract();
    let (r,s)=sign_valid_transaction();
    let is_valid=account.is_valid_signature(TX_HASH,array![r,s]);
    assert_eq!(is_valid, starknet::VALIDATED);
    
}

#[test]
fn test_invalid_signature(){
    let (account,_) =account_contract();
   
   
    let (r,s)=sign_invalid_transaction('invalid_sig');
   
    let is_valid=account.is_valid_signature(TX_HASH,array![r,s]);
    assert_eq!(is_valid, 0);
    assert_ne!(is_valid, starknet::VALIDATED);
   
}
#[test]
fn test_reconfirm_invalid_signature(){
    let (account,_) =account_contract();
    let (r,s)=sign_invalid_transaction('another_wrong_secret_key');
    let is_valid=account.is_valid_signature(TX_HASH,array![r,s]);
    assert_eq!(is_valid, 0);
    assert_ne!(is_valid, starknet::VALIDATED);
}







use snforge_std::{
    start_cheat_caller_address,start_cheat_transaction_hash,
    start_cheat_signature,
   
};
use super::utils::{NUTRON_WALLET_ADDRESS,deploy_account,TX_HASH,sign_valid_transaction,sign_invalid_transaction};
use nutron_wallet_contract::account::{IProtocolAccountDispatcher,IProtocolAccountDispatcherTrait};


#[test]
fn test_valid__execute__(){
    let contract_address =deploy_account("Account");
    let wallet= IProtocolAccountDispatcher { contract_address};
    start_cheat_caller_address(NUTRON_WALLET_ADDRESS.try_into().unwrap(),starknet::contract_address_const::<0>());
     
    start_cheat_transaction_hash(NUTRON_WALLET_ADDRESS.try_into().unwrap(),TX_HASH);
    let (r,s)=sign_valid_transaction();
    start_cheat_signature(NUTRON_WALLET_ADDRESS.try_into().unwrap(),array![r,s].span());
    
   
    let calls:Array<starknet::account::Call> =ArrayTrait::new();
    wallet.__execute__(calls);
}
#[test]
#[should_panic(expected:'ERROR: invalid signature')]
fn test_invalid__execute__(){
    let contract_address =deploy_account("Account");
    let wallet= IProtocolAccountDispatcher { contract_address};
    start_cheat_caller_address(NUTRON_WALLET_ADDRESS.try_into().unwrap(),starknet::contract_address_const::<0>());
     
    start_cheat_transaction_hash(NUTRON_WALLET_ADDRESS.try_into().unwrap(),TX_HASH);
    let (r,s)=sign_invalid_transaction('invalid_execute__signature');
    start_cheat_signature(NUTRON_WALLET_ADDRESS.try_into().unwrap(),array![r,s].span());
    
   
    let calls:Array<starknet::account::Call> =ArrayTrait::new();
    wallet.__execute__(calls);
}


#[test]
fn test_valid__validate__(){
    
        let contract_address =deploy_account("Account");
        let wallet= IProtocolAccountDispatcher { contract_address};
        start_cheat_caller_address(NUTRON_WALLET_ADDRESS.try_into().unwrap(),starknet::contract_address_const::<0>());
         
        start_cheat_transaction_hash(NUTRON_WALLET_ADDRESS.try_into().unwrap(),TX_HASH);
        let (r,s)=sign_valid_transaction();
        start_cheat_signature(NUTRON_WALLET_ADDRESS.try_into().unwrap(),array![r,s].span());
        
       
        let calls:Array<starknet::account::Call> =ArrayTrait::new();
        wallet.__validate__(calls);
}

#[test]
#[should_panic(expected:'ERROR: invalid signature')]
fn test_invalid__validate__(){
    let contract_address =deploy_account("Account");
    let wallet= IProtocolAccountDispatcher { contract_address};
    start_cheat_caller_address(NUTRON_WALLET_ADDRESS.try_into().unwrap(),starknet::contract_address_const::<0>());
     
    start_cheat_transaction_hash(NUTRON_WALLET_ADDRESS.try_into().unwrap(),TX_HASH);
    let (r,s)=sign_invalid_transaction('invalid_validate__signature');
    start_cheat_signature(NUTRON_WALLET_ADDRESS.try_into().unwrap(),array![r,s].span());
    
   
    let calls:Array<starknet::account::Call> =ArrayTrait::new();
    wallet.__validate__(calls);
}

use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait,DeclareResultTrait,start_cheat_transaction_hash};
use nutron_wallet_contract::account::{IAccountDispatcher,IAccountDispatcherTrait};
use snforge_std::signature::{
    KeyPairTrait, stark_curve::{StarkCurveKeyPairImpl, StarkCurveSignerImpl, StarkCurveVerifierImpl},
};

const SECRET_KEY:felt252= 'nutron_wallet_account';
const TX_HASH:felt252 =0x22222222222;

fn gen_public_key()->felt252{
    let account_owner = KeyPairTrait::from_secret_key(SECRET_KEY);
    account_owner.public_key
}

fn deploy_account(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();
    
   let (contract_address, _) = contract.deploy(@array![gen_public_key()]).unwrap();
   contract_address
  
}

fn account_contract()->(IAccountDispatcher,ContractAddress){
    let account_address =deploy_account("Account");
    let account = IAccountDispatcher {contract_address: account_address};
    (account,account_address)
}
#[test]
fn test_public_key(){
   let (account,_) =account_contract();
  println!("public key is {}",account.public_key());
  assert_eq!(account.public_key(), gen_public_key());
}


#[test]
fn test_valid_signature(){
    let (account,_) =account_contract();
    let account_owner = KeyPairTrait::from_secret_key(SECRET_KEY);
    let (r,s)=account_owner.sign(TX_HASH).unwrap();
    let is_valid=account.is_valid_signature(TX_HASH,array![r,s]);
    assert_eq!(is_valid, starknet::VALIDATED);
    
}

#[test]
fn test_invalid_signature(){
    let (account,_) =account_contract();
    let account_owner = KeyPairTrait::from_secret_key('wrong key');
    let (r,s)=account_owner.sign(TX_HASH).unwrap();
    let is_valid=account.is_valid_signature(TX_HASH,array![r,s]);
    assert_eq!(is_valid, 0);
    
}





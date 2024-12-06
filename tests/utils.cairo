use nutron_wallet_contract::account::{IAccountDispatcher};
use snforge_std::{declare, ContractClassTrait,DeclareResultTrait};
use snforge_std::signature::{
    KeyPairTrait, stark_curve::{StarkCurveKeyPairImpl, StarkCurveSignerImpl, StarkCurveVerifierImpl},
};
use starknet::ContractAddress;

pub const ACCOUNT_REGISTRY_TEST_ADDRESS:felt252 = 'ACCOUNT_REGISTRY';
pub const TX_HASH:felt252 =0x22222222222;

pub const SECRET_KEY:felt252= 'nutron_wallet_account';
pub const NUTRON_WALLET_ADDRESS:felt252 ='nutron_wallet_address';
pub const TEST_RECIPIENT_ADDRESS:felt252='recipient';
pub const TEST_ACCOUNT_NAME:felt252='osas.nutron';

pub fn deploy_registry()->starknet::ContractAddress{
    let contract_class = declare("GlobalAccountRegistry").unwrap().contract_class();
    let (address, _)= contract_class.deploy_at(@ArrayTrait::new(),ACCOUNT_REGISTRY_TEST_ADDRESS.try_into().unwrap()).unwrap();
    address
 }
pub fn deploy_account(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();
   
    let account_registry_address = deploy_registry();
     // public_key: felt252,account_name:felt252,account_registry:ContractAddress
   let (contract_address, _) = contract.deploy_at(@array![gen_public_key(),TEST_ACCOUNT_NAME,account_registry_address.try_into().unwrap()],NUTRON_WALLET_ADDRESS.try_into().unwrap()).unwrap();
   contract_address
}


pub fn account_contract()->(IAccountDispatcher,ContractAddress){
    let account_address =deploy_account("Account");
    let account = IAccountDispatcher {contract_address: account_address};
    (account,account_address)
}

pub fn gen_public_key()->felt252{
    let account_owner = KeyPairTrait::from_secret_key(SECRET_KEY);
    account_owner.public_key
}
pub fn sign_valid_transaction()->(felt252,felt252){
    let account_owner = KeyPairTrait::from_secret_key(SECRET_KEY);
    let (r,s)=account_owner.sign(TX_HASH).unwrap();
    (r,s)
}
pub fn sign_invalid_transaction(key:felt252)->(felt252,felt252){
  
    let account_owner = KeyPairTrait::from_secret_key(key);
    let (r,s)=account_owner.sign(TX_HASH).unwrap();
    (r,s)
}

pub fn deploy_contract(name:ByteArray ,args: Array<felt252>)->ContractAddress{
    let contract_class = declare(name).unwrap().contract_class();
    let (contract_address,_)= contract_class.deploy(@args).unwrap();
    contract_address
}




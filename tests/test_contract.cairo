use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait};
use nutron_wallet_contract::IAccountDispatcher;
// use core::serde::Serde;


#[derive(Drop,Serde)]
struct AccountArg{
  public_key: felt252
}
const PUBLIC_KEY:felt252 = 2345677889;
fn deploy_account() -> ContractAddress {
    let contract = declare("Account").unwrap();
    let args = AccountArg {public_key : PUBLIC_KEY };
    let mut constructor_args =ArrayTrait::new();
    args.serialize(ref constructor_args);
    let (contract_address, _) = contract.deploy(@constructor_args).unwrap();
    contract_address
}


fn test_deploy(){

    let account =deploy_account();
    
    

}

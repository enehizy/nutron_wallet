use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait};

use nutron_wallet_contract::account::{IAccountDispatcher};



#[derrive(Drop,Serde)]
struct AccountArg{
  public_key: felt252
}
const PUBLIC_KEY:felt252 = 2345677889;
fn deploy_account() -> ContractAddress {
    let contract = declare("Account").unwrap();
    let args = AccountArg {public_key : PUBLIC_KEY };
    let (contract_address, _) = contract.deploy(args.serialize().span()).unwrap();
    println!("{:?}",args.serialize().span());
    contract_address
}


fn test_deploy(){

    let account =deploy_account();

    

}

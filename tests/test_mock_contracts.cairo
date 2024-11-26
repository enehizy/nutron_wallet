use nutron_wallet_contract::account::IProtocolAccountDispatcherTrait;
use starknet::{ContractAddress,account::Call};
use nutron_wallet_contract::account::{IProtocolAccountDispatcher};
use nutron_wallet_contract::mocks::erc20::{IERC20Dispatcher,IERC20DispatcherTrait};
use snforge_std::{start_cheat_caller_address};
use super::utils::{NUTRON_WALLET_ADDRESS,deploy_contract,deploy_account,sign_valid_transaction,TX_HASH};
#[derive(Drop,Serde)]
struct ERC20_ARGS{
    recipient: ContractAddress,
    name: felt252,
    decimals: u8,
    initial_supply: felt252,
    symbol: felt252
}

fn deploy_erc20()->(IERC20Dispatcher,ContractAddress){
    let mut args = ArrayTrait::new();
    let constructor = ERC20_ARGS {
        recipient:NUTRON_WALLET_ADDRESS.try_into().unwrap(),
        name:'test_erc20',
        decimals:18,
        initial_supply: 100_000_000,
        symbol:'nusd'
    };
    constructor.serialize(ref args);
  let contract_address = deploy_contract("ERC20",args);
   (IERC20Dispatcher {contract_address},contract_address)

}

#[derive(Drop,Serde)]
struct TokenCalldata{
    recipient:ContractAddress,
    amount : felt252
}
#[derive(Drop,Serde)]
struct TokenFromCalldata{
    sender: ContractAddress,
    recipient: ContractAddress,
    amount: felt252
}



#[test]
fn test_erc20_multicalls(){
    let TEST_ACCOUNT = 'osas'.try_into().unwrap();
    let TEST_AMOUNT = 10000;
    let wallet_address = deploy_account("Account");
    let wallet = IProtocolAccountDispatcher { contract_address: wallet_address};
    let (token,token_address) = deploy_erc20();

    // transfer and approve calls`
    let mut  calldata = ArrayTrait::new();
    let calldata_struct = TokenCalldata { recipient: TEST_ACCOUNT, amount: TEST_AMOUNT};
    calldata_struct.serialize(ref calldata);
    let transfer_call = Call { to : token_address, selector:selector!("transfer"),calldata:calldata.span()};
    let approve_call = Call { to : token_address, selector:selector!("approve"),calldata:calldata.span()};
    
    // transfer_from calls`
    let mut  calldata = ArrayTrait::new();
    let calldata_struct = TokenFromCalldata {sender:wallet_address, recipient: TEST_ACCOUNT, amount: TEST_AMOUNT};
    calldata_struct.serialize(ref calldata);
    let transfer_from_call = Call { to : token_address, selector:selector!("transfer_from"),calldata:calldata.span()};


    start_cheat_caller_address(wallet_address,starknet::contract_address_const::<0>());
   
    let (r,s)=sign_valid_transaction();
    snforge_std::start_cheat_transaction_hash(wallet_address,TX_HASH);
    snforge_std::start_cheat_signature(wallet_address,array![r,s].span());


    let current_estimated_balance =TEST_AMOUNT* 2;
    wallet.__execute__(array![transfer_call,approve_call,transfer_from_call]);
    let recipient_balance = token.balance_of(TEST_ACCOUNT);

    assert_eq!(recipient_balance, current_estimated_balance);

}
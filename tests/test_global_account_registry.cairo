
use nutron_wallet_contract::global_account_registry::{IGlobalAccountRegistryDispatcher,IGlobalAccountRegistryDispatcherTrait};
use super::utils::{deploy_registry,deploy_account,TEST_ACCOUNT_NAME,ACCOUNT_REGISTRY_TEST_ADDRESS,NUTRON_WALLET_ADDRESS}; 

 


#[test]
fn test_address_deploy(){
    let address = deploy_registry();
    assert_eq!(address, ACCOUNT_REGISTRY_TEST_ADDRESS.try_into().unwrap(),"ADDRESS DOESNT MATCH");
}
#[should_panic(expected :'Only account owner can register')]
#[test]
fn test_failed_register_account(){
   let contract_address = deploy_registry();
    let registrar = IGlobalAccountRegistryDispatcher {contract_address};
    registrar.register_account('osas.nutron','osas'.try_into().unwrap())

}
#[test]
fn test_sucessful_account_registration(){
    deploy_account("Account");
    let registrar = IGlobalAccountRegistryDispatcher {contract_address: ACCOUNT_REGISTRY_TEST_ADDRESS.try_into().unwrap()};

   assert_eq!(registrar.get_account_address(TEST_ACCOUNT_NAME), NUTRON_WALLET_ADDRESS.try_into().unwrap());
}
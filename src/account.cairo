use starknet::account::Call;
#[starknet::interface]
pub trait IAccount<T> {
    fn public_key(self: @T) -> felt252;
    fn is_valid_signature(self: @T, hash: felt252, signature: Array<felt252>) -> felt252;
    fn supports_interface(self: @T, interface_id: felt252) -> bool;
}

#[starknet::interface]
trait IProtocolAccountTrait<T>{
    fn __validate__(self: @T, calls: Array<Call>) -> felt252 ;
    fn __validate_declare__(self: @T, class_hash: felt252) -> felt252 ;
    fn __validate_deploy__(
        self: @T, class_hash: felt252, salt: felt252, public_key: felt252
    ) -> felt252 ; 
    fn __execute__(self: @T, calls: Array<Call>) -> Array<Span<felt252>>; 
}

#[starknet::contract(account)]
mod Account {
 
use super::IAccount;
const ISRC6_ID: felt252 = 0x2ceccef7f994940b3962a6c67e0ba4fcd37df7d131417c604f91e03caecc1cd;
    #[storage]
    struct Storage {
        public_key:felt252,
        version: felt252
    }
    
    use super::Call;
   use core::num::traits::Zero;
   
    mod Errors{
        pub const INVALID_SIGNATURE:felt252='invalid signature';
    }
    mod SUPPORTED_TX_VERSION {
        // Constants representing the supported versions
       pub const DEPLOY_ACCOUNT: felt252 = 1;  // Supported version for deploy_account transactions
       pub const DECLARE: felt252 = 2;         // Supported version for declare transactions
       pub  const INVOKE: felt252 = 1;          // Supported version for invoke transactions
      }

    #[constructor]
    fn constructor(ref self: ContractState, public_key: felt252) {
        self.public_key.write(public_key);
    }


    

    #[abi(embed_v0)]
    impl IAccounImpl of super::IAccount<ContractState> {
        fn public_key(self: @ContractState) -> felt252 {
            self.public_key.read()
        }
        fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
            interface_id == ISRC6_ID
        }
        fn is_valid_signature(
            self: @ContractState, hash: felt252, signature: Array<felt252>
        ) -> felt252 {
           self.is_valid_signature(hash,signature);
           starknet::VALIDATED
        }
    }
   
    
    #[abi(embed_v0)]
    impl ProtocolAccountImpl of super::IProtocolAccountTrait<ContractState>{
        fn __execute__(self: @ContractState, calls: Array<Call>) -> Array<Span<felt252>> {
          self.validate_transaction();
          let tx_info=self._get_tx_info();
          assert(tx_info.version == SUPPORTED_TX_VERSION::INVOKE,Errors::INVALID_SIGNATURE);
         ArrayTrait::new() 

            
        }
        fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252 {
            self.validate_transaction();
            let tx_info=self._get_tx_info();
            assert(tx_info.version == SUPPORTED_TX_VERSION::INVOKE,Errors::INVALID_SIGNATURE);

            starknet::VALIDATED
        }
        fn __validate_declare__(self: @ContractState, class_hash: felt252) -> felt252 {
            self.validate_transaction();
          let tx_info=self._get_tx_info();
          assert(tx_info.version == SUPPORTED_TX_VERSION::DECLARE,Errors::INVALID_SIGNATURE);
        
          starknet::VALIDATED
        }
        fn __validate_deploy__(
            self: @ContractState, class_hash: felt252, salt: felt252, public_key: felt252
        ) -> felt252 {
            self.validate_transaction();
           let tx_info=self._get_tx_info();
           assert(tx_info.version == SUPPORTED_TX_VERSION::DEPLOY_ACCOUNT,Errors::INVALID_SIGNATURE);

           starknet::VALIDATED
        }
    }

    #[generate_trait]
    impl Utils of IAccountUtils {
        fn is_protocol(self :@ContractState) {
            let caller = starknet::get_caller_address();
            assert(caller.is_zero(), 'Only Protocol Can Call');
        }
        fn _is_valid_signature(self :@ContractState,msg_hash:felt252,signature:Span<felt252>)->bool{
            if signature.len() > 2{
               return false;
            }
            core::ecdsa::check_ecdsa_signature(msg_hash,self.public_key.read(),*signature.at(0),*signature.at(1))
        }
        fn validate_transaction(self:@ContractState){
           let tx_data =self._get_tx_info();
           let signature =tx_data.signature;
           let msg_hash=tx_data.transaction_hash;
           self.is_protocol();
           assert(self._is_valid_signature(msg_hash,signature),Errors::INVALID_SIGNATURE);
          

        }
        fn _get_tx_info(self:@ContractState)->starknet::TxInfo{
            let tx_data =starknet::get_tx_info().unbox();
            tx_data

        }
    }
}

use starknet::account::Call;
#[starknet::interface]
pub trait IAccount<T> {
    fn public_key(self: @T) -> felt252;
    fn is_valid_signature(self: @T, hash: felt252, signature: Array<felt252>) -> felt252;
    fn supports_interface(self: @T, interface_id: felt252) -> bool;
}

#[starknet::interface]
pub trait IProtocolAccount<T>{
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
use core::iter::IntoIterator;
const ISRC6_ID: felt252 = 0x2ceccef7f994940b3962a6c67e0ba4fcd37df7d131417c604f91e03caecc1cd;
    #[storage]
    struct Storage {
        public_key:felt252,
        version: felt252
    }
    
    use super::Call;
   use core::num::traits::Zero;
   use starknet::syscalls::call_contract_syscall;
    mod Errors{
        pub const INVALID_SIGNATURE:felt252='invalid signature';
        pub const   INVALID_TRANSACTION_VERSION:felt252='invalid tx version';
    }
  
    #[constructor]
    fn constructor(ref self: ContractState, public_key: felt252) {
        self.public_key.write(public_key);
        self.version.write('beta');
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
          if self._is_valid_signature(hash,signature.span()){
            starknet::VALIDATED
          }else{
                 0
          }
         
        }
    }
   
    
    #[abi(embed_v0)]
    impl ProtocolAccountImpl of super::IProtocolAccount<ContractState>{
        fn __execute__(self: @ContractState,calls: Array<Call>) -> Array<Span<felt252>> {
            
          self.validate_transaction();
        let tx_info= starknet::get_tx_info().unbox();
        let tx_version =tx_info.version;
        assert(tx_version != 0, Errors::INVALID_TRANSACTION_VERSION);
        
         let mut results:Array<Span<felt252>> = ArrayTrait::new();
        
         
         for call in calls.into_iter(){
           let res =call_contract_syscall(call.to,call.selector,call.calldata).unwrap();
           results.append(res);
         };
        results
           
        }
        fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252 {
           
            self.validate_transaction();
            starknet::VALIDATED
        }
        fn __validate_declare__(self: @ContractState, class_hash: felt252) -> felt252 {
            self.validate_transaction();
        
          starknet::VALIDATED
        }
        fn __validate_deploy__(
            self: @ContractState, class_hash: felt252, salt: felt252, public_key: felt252
        ) -> felt252 {
            self.validate_transaction();
    

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
            if signature.len() == 2{
              return core::ecdsa::check_ecdsa_signature(msg_hash,self.public_key.read(),*signature.at(0),*signature.at(1));
            }
            false
            
        }
        fn validate_transaction(self:@ContractState){
            self.is_protocol();
           let tx_data =starknet::get_tx_info().unbox();
         
           let signature:Array<felt252> =tx_data.signature.into();
           let msg_hash=tx_data.transaction_hash;
            assert(self.is_valid_signature(msg_hash,signature) == starknet::VALIDATED,Errors::INVALID_SIGNATURE);
       

        }
       
        
    }
}

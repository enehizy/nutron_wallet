use starknet::account::Call;
// Define the 1SRC5 interfaces for account 
#[starknet::interface]
pub trait IAccount<T> {
    /// @notice Retrieves the public key associated with the account.
    /// @return The public key as a `felt252`.
    fn public_key(self: @T) -> felt252;
    /// @notice Validates the signature of an account with already stored public key.
    /// @param hash The message hash to validate.
    /// @param signature An array representing the digital signature.
    /// @return A felt252 indicating whether the signature is valid.
    fn is_valid_signature(self: @T, hash: felt252, signature: Array<felt252>) -> felt252;
     /// @notice Checks if the contract supports a specific interface ID.
    /// @param interface_id The ID of the interface to check.
    /// @return True if the interface is supported, false otherwise.å
    fn supports_interface(self: @T, interface_id: felt252) -> bool;
}
// Define Protocol level account abstration calls
#[starknet::interface]
pub trait IProtocolAccount<T>{
     /// @notice Validates a batch of protocol-level calls.
    /// @param calls An array of `Call` structs representing the calls.
    /// @return A felt252 indicating the result of the validation.
    fn __validate__(self: @T, calls: Array<Call>) -> felt252 ;
    /// @notice Validates the `declare` operation.
    /// @param class_hash The hash of the class being declared.
    /// @return A `felt252` indicating the validation result.
    fn __validate_declare__(self: @T, class_hash: felt252) -> felt252 ;
      /// @notice Validates the `deploy` operation.
    //   @param class_hash The hash of the contract class.
    //    @param salt The deployment salt.
    //    @param public_key The public key for the account.
    //    @return A `felt252` value indicating validation status.
    fn __validate_deploy__(
        self: @T, class_hash: felt252, salt: felt252, public_key: felt252
    ) -> felt252 ; 
  
    //   @notice Executes a batch of calls on behalf of the account.
    //  @param calls An array of `Call` structs to execute.
    //  @return An array of spans containing the results of each call.
     
    fn __execute__(self: @T, calls: Array<Call>) -> Array<Span<felt252>>;
}
    
#[starknet::contract(account)]
mod Account {

use nutron_wallet_contract::global_account_registry::{IGlobalAccountRegistryDispatcher,IGlobalAccountRegistryDispatcherTrait};
use super::IAccount;
use starknet::ContractAddress;
use core::iter::IntoIterator;

type P256PublicKey = starknet::secp256r1::Secp256r1Point;
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
        pub const INVALID_SIGNATURE:felt252='ERROR: invalid signature';
        pub const   INVALID_TRANSACTION_VERSION:felt252='ERROR: invalid tx version';
        pub const ONLY_PROTOCOL:felt252 ='ERROR: Protocol-only action';
    }
      /// @notice Constructor for initializing the account contract.
    /// @param self The account state.
    /// @param public_key The public key of the account.
    /// @param account_name The name of the account.
    /// @param account_registry The address of the account registry contract.
    #[constructor]
    fn constructor(ref self: ContractState, public_key: felt252,account_name:felt252,account_registry:ContractAddress) {
        self.public_key.write(public_key);
        self.version.write('beta');
        
        IGlobalAccountRegistryDispatcher {contract_address:account_registry}
        .register_account(account_name,starknet::get_contract_address())
    }


    

    #[abi(embed_v0)]
    impl IAccounImpl of super::IAccount<ContractState> {
    
         /// @inheritdoc
        fn public_key(self: @ContractState) -> felt252 {
            self.public_key.read()
        }
        /// @inheritdoc
        fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
            interface_id == ISRC6_ID
        }
         /// @inheritdoc
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
         /// @inheritdoc
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
         /// @inheritdoc
        fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252 {
           
            self.validate_transaction();
            starknet::VALIDATED
        }
        fn __validate_declare__(self: @ContractState, class_hash: felt252) -> felt252 {
            self.validate_transaction();
        
          starknet::VALIDATED
        }
         /// @inheritdoc
        fn __validate_deploy__(
            self: @ContractState, class_hash: felt252, salt: felt252, public_key: felt252
        ) -> felt252 {
            self.validate_transaction();
    

           starknet::VALIDATED
        }
        
    }

    #[generate_trait]
    impl Utils of IAccountUtils {
        /// @notice Ensures the caller is the protocol.
        /// @dev Reverts if the caller is not the protocol.
        fn is_protocol(self :@ContractState) {
            let caller = starknet::get_caller_address();
            assert(caller.is_zero(), Errors::ONLY_PROTOCOL);
        }
        /// @notice utility/private function to verify signature of an account.
        /// @param msg_hash The hash of the message to validate.
        /// @param signature The digital signature to verify.
        /// @return True if the signature is valid, false otherwise.
        fn _is_valid_signature(self :@ContractState,msg_hash:felt252,signature:Span<felt252>)->bool{
            if signature.len() == 2{
              return core::ecdsa::check_ecdsa_signature(msg_hash,self.public_key.read(),*signature.at(0),*signature.at(1));
            }
            false
            
        }
        /// @notice Validates the current transaction.
        /// @dev Ensures the transaction has a valid signature and was initiated by the protocol.
        fn validate_transaction(self:@ContractState){
            self.is_protocol();
           let tx_data =starknet::get_tx_info().unbox();
         
           let signature:Array<felt252> =tx_data.signature.into();
           let msg_hash=tx_data.transaction_hash;
            assert(self.is_valid_signature(msg_hash,signature) == starknet::VALIDATED,Errors::INVALID_SIGNATURE);
       

        }
       
        
    }
}

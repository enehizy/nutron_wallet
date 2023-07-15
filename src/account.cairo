const ERC165_ACCOUNT_ID: u32 = 0xa66bd575_u32;
const INVALID_ID: u32 = 0xffffffff_u32;
use starknet::account::Call;
use array::ArrayTrait;

trait IERC165<TContractState> {
  fn supports_interface(self :@TContractState,interface_id: u32) -> bool;
}
trait AccountContract<TContractState> {
    fn __validate_declare__(self: @TContractState, class_hash: felt252) -> felt252;
    fn __validate__(ref self: TContractState, calls: Array<Call>) -> felt252;
    fn __execute__(ref self: TContractState, calls: Array<Call>) -> Array<Span<felt252>>;
}

#[starknet::contract]
mod Account {
    
    use super::{
      ERC165_ACCOUNT_ID,
      IERC165,
      INVALID_ID
    };
    use nutron_wallet_contract::spending_limit_manager::{
        ISpendingLimitManagerLibraryDispatcher,
        ISpendingLimitManagerDispatcherTrait
    };
   use box::BoxTrait;
    use starknet::{
        get_caller_address,
        call_contract_syscall,VALIDATED,
        get_tx_info,ContractAddress,
        account::Call};
       
    



   
    
    use array::{ArrayTrait,SpanTrait,ArraySerde};
   
    
    use ecdsa::check_ecdsa_signature;
   
    use zeroable::Zeroable;
  

   
    
    use option::OptionTrait;
   
    
   
    #[storage]
    struct Storage {
        public_key: felt252,
        supported_interfaces: LegacyMap<u32, bool>,
    }

    
    #[constructor]
    fn constructor(ref self :ContractState,_public_key: felt252) {
        self.register_interface(ERC165_ACCOUNT_ID);
        self.public_key.write(_public_key);
    }

    ////////////////////////////////
    // __validate_declare__ validates account declare tx - enforces fee payment
    ////////////////////////////////
    #[external(v0)]
    fn __validate_deploy__(
        self: @ContractState,
        class_hash: felt252,
        contract_address_salt: felt252,
        public_key_: felt252
    ) -> felt252 {
        self.validate_transaction()
    }

#[generate_trait]
   impl ERC165Utils of ERC165UtilsTrait{
     fn register_interface(ref self: ContractState,interface_id: u32) {
            assert(interface_id != INVALID_ID, 'Invalid id');
            self.supported_interfaces.write(interface_id, true);
        }

   
        fn deregister_interface(ref self: ContractState,interface_id: u32) {
            assert(interface_id !=  ERC165_ACCOUNT_ID, 'Invalid id');
            self.supported_interfaces.write(interface_id, false);
        }
    

}
    #[generate_trait]
    impl AccountUtilsImpl of AccountUtilsTrait{
       
         fn validate_transaction(self: @ContractState) -> felt252 {
            let tx_info = starknet::get_tx_info().unbox();
            let signature = tx_info.signature;
            assert(signature.len() == 2_u32, 'INVALID_SIGNATURE_LENGTH');
            assert(
                check_ecdsa_signature(
                    message_hash: tx_info.transaction_hash,
                    public_key: self.public_key.read(),
                    signature_r: *signature[0_u32],
                    signature_s: *signature[1_u32],
                ),
                'INVALID_SIGNATURE',
            );

            starknet::VALIDATED
        }


       
    }
    #[external(v0)]
    impl ERC165 of IERC165<ContractState> {
        fn supports_interface(self:@ContractState,interface_id: u32) -> bool {
            if interface_id ==  ERC165_ACCOUNT_ID {
                return true;
            }
            self.supported_interfaces.read(interface_id)
        }
    }
   
   
    #[external(v0)]
    impl AccountImpl of super::AccountContract<ContractState>{
        fn __validate_declare__(self: @ContractState, class_hash: felt252) -> felt252 {
            self.validate_transaction()
        } 
        fn __validate__(ref self:ContractState, calls :Array<Call>)->felt252{
            self.validate_transaction()
        }

        

        fn __execute__(ref self: ContractState, calls: Array<Call>) -> Array<Span<felt252>> {

            //shadowing calls
            let mut calls =calls;
            // Validate caller.
            assert(get_caller_address().is_zero(), 'INVALID_CALLER');

            // Check the tx version here, since version 0 transaction skip the __validate__ function.
            let tx_info = get_tx_info().unbox();
            assert(tx_info.version != 0, 'INVALID_TX_VERSION');

            let mut result = ArrayTrait::new();
            loop {
                match calls.pop_front() {
                    Option::Some(call) => {
                        let mut res = call_contract_syscall(
                            address: call.to,
                            entry_point_selector: call.selector,
                            calldata: call.calldata.span()
                        )
                            .unwrap_syscall();
                        result.append(res);
                    },
                    Option::None(()) => {
                        break; 
                    },
                };
            };
           return result;
        }
    }
     
    

 


}




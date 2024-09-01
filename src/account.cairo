#[starknet::interface]
trait IAccount<T> {
    fn public_key(self: @T) -> felt252;
    fn supports_interface(self: @T, interface_id: felt252) -> bool;
    fn is_valid_signature(self: @T, hash: felt252, signature: Array<felt252>) -> felt252;
}
#[starknet::contract(account)]
mod Account {
    #[storage]
    struct Storage {
        public_key:felt252
    }
   
   #[abi(embed_v0)]
   impl IAccounImpl of IAccount<ContractState>{
    fn public_key(self: @ContractState) -> felt252{

    }
    fn supports_interface(self: @ContractState, interface_id: felt252) -> bool{

    }
    fn is_valid_signature(self: @ContractState, hash: felt252, signature: Array<felt252>) -> felt252{

    }
   }
   #[abi(embed_v0)]
   #[generate_trait]
   impl ProtocolAccountImpl of IProtocolAccountTrait{
    fn __execute__(self: @ContractState, calls: Array<Call>) -> Array<Span<felt252>>{

    }
    fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252{
        
    }
    fn __validate_declare__(self: @ContractState, class_hash: felt252) -> felt252{

    }
    fn __validate_deploy__(self: @ContractState, class_hash: felt252, salt: felt252, public_key: felt252) -> felt252{

    };
   }

   
    
}

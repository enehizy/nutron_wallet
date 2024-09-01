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
        public_key:NoneZero<felt252>,
        src5: SRC5Component::Storage,
        version:felt252
    }
    use openzeppelin_introspection::src5::SRC5Component;
    component!(path:SRC5Component , storage:src5 , event: SRC5Event);

    // impl IntrospectionInternals = SRC5Component::SRC5MixinImpl<ContractState>;
    impl IntrospectionInternals = SRC5Component::InternalImpl<ContractState>;
    


    
    #[event]
    #[derive(starknet::Event,Drop)]
    enum Event{
        SRC5Event:SRC5Component::Event
    }

   #[abi(embed_v0)]
   impl IAccounImpl of IAccount<ContractState>{
    fn public_key(self: @ContractState) -> felt252{
      self.public_key.read()
    }
    fn supports_interface(self: @ContractState, interface_id: felt252) -> bool{
     self._supports_interface(interface_id)
    }
    fn is_valid_signature(self: @ContractState, hash: felt252, signature: Array<felt252>) -> felt252{
       starknet::VALIDATED;
    }
   }
   #[abi(embed_v0)]
   #[generate_trait]
   impl ProtocolAccountImpl of IProtocolAccountTrait{
    fn __execute__(self: @ContractState, calls: Array<Call>) -> Array<Span<felt252>>{
        self.is_protocol();
        let mut  res= ArrayTrait::new();
        res.append('hello')
        res

    }
    fn __validate__(self: @ContractState, calls: Array<Call>) -> felt252{
        self.is_protocol();
        0
        
    }
    fn __validate_declare__(self: @ContractState, class_hash: felt252) -> felt252{
        self.is_protocol();
        0

    }
    fn __validate_deploy__(self: @ContractState, class_hash: felt252, salt: felt252, public_key: felt252) -> felt252{
        self.is_protocol();
    0
    };
   }
   
   impl Utils for IAccountUtils{
     fn is_protocol()->{
        let caller = starknet::get_caller_address();
        assert(caller.is_zero(),'Only Protocol Can Call');
     }

   }
   
    
}

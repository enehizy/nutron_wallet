use starknet::ContractAddress;

#[starknet::interface]
pub trait IGlobalAccountRegistry<TState>{
    fn register_account(ref self:TState,name : felt252 , address :ContractAddress);
    fn get_account_address(self:@TState,name:felt252)->ContractAddress;
}




#[starknet::contract]
mod GlobalAccountRegistry{
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, 
    };
   use super::ContractAddress;

   #[storage]
   struct Storage{
      account: Map<felt252,ContractAddress> 
   }
  
   mod ERRORS{
     pub const ONLY_CALLED_ON_ACCOUNT_CREATION:felt252 = 'ERROR: call in a constructor';
   }
  #[abi(embed_v0)]
   impl IGlobalAccountRegistryImpl of super::IGlobalAccountRegistry<ContractState>{
    fn register_account(ref self:ContractState,name : felt252 , address :ContractAddress){
        let caller =starknet::get_caller_address();
        assert(caller == address,ERRORS::ONLY_CALLED_ON_ACCOUNT_CREATION);
        self.account.write(name,address);

    }
    fn get_account_address(self:@ContractState,name:felt252)->ContractAddress{
        self.account.read(name)
    }
  }
   
}
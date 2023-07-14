use starknet::ContractAddress;

#[starknet::interface]
trait ISpendingLimitManager<T>{

   fn get_allowance(self:@T, public_key:felt252 ,token: ContractAddress)->u256;

   fn set_allowance(ref self :T, public_key:felt252 ,token: ContractAddress,amount:u256)->();


   fn is_allowed(self :@T,public_key:felt252,token: ContractAddress,amount:u256)-> bool;
   
  
}

#[starknet::contract]
mod SpendingLimitManger{

   use starknet::ContractAddress;
   use starknet::get_caller_address;
   use starknet::get_contract_address;

   #[storage]
   struct Storage {
     //mapping of public_key ,token_address to amount
     allowance : LegacyMap<(felt252,ContractAddress),u256>
   }


   #[external(v0)]
   impl SpendingLimitManger of super::ISpendingLimitManager<ContractState>{
      
       fn set_allowance(ref self:ContractState,public_key:felt252 ,token: ContractAddress,amount:u256){
           _assert_only_self();
           self.allowance.write((public_key,token),amount);
       }

        fn get_allowance(self :@ContractState, public_key:felt252 ,token: ContractAddress)->u256 {
            self.allowance.read((public_key,token))
        }
      
      fn is_allowed(self :@ContractState,public_key:felt252 ,token: ContractAddress,amount:u256)-> bool {
          let allowed= self.allowance.read((public_key,token));
          if amount <= allowed  { return true;} 
         return false;
      }
     
   }
   
   
   
   fn _assert_only_self() {
        let caller = get_caller_address();
        let self = get_contract_address();
        assert(self == caller, 'Account: unauthorized');
    } 
}
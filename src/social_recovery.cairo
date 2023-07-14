#[contract]
mod SocialRecovery{
    use starknet::ContractAddress;
    use AccountLib::AccountLib;
    struct Storage {
        guardians: Array<ContractAddress>,
    }
   
   fn setGuardian(new_guardian:ContractAddress){
      AccountLib::_assert_only_self();
      guardian::write(new_guardian);

   }
   


}
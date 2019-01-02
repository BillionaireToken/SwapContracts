pragma solidity ^0.5.2;


contract XBL_ERC20Wrapper
{
    function transferFrom(address from, address to, uint value) public returns (bool success);
    function allowance(address _owner, address _spender) public  returns (uint256 remaining);
    function balanceOf(address _owner) public returns (uint256 balance);
}


contract SwapContrak 
{
    string eosio_username;
    uint256 register_counter;
    mapping(string => uint256) registered_for_swap_database; // String = eosio_username , uint256 = XBL balance.
    mapping(uint256 => string) address_to_eosio_username; //uint256 = index String = eosio_username.

    address public swap_address;
    address public XBLContract_addr;
    XBL_ERC20Wrapper private ERC20_CALLS;


    constructor() public
    {
        swap_address = address(this); /* Own address */
        register_counter = 0;
        XBLContract_addr = 0xef55BfAc4228981E850936AAf042951F7b146e41;
        ERC20_CALLS = XBL_ERC20Wrapper(XBLContract_addr);
    }

    function getPercent(uint8 percent, uint256 number) private returns (uint256 result)
    {
        return number * percent / 100;
    }
    

    function registerSwap(uint256 xbl_amount, string memory eosio_username) public returns (int256 STATUS_CODE)
    {
        uint256 balance;
        // -1 = allowance mismatch
        // -2 = balance mismatch
        if (ERC20_CALLS.allowance(msg.sender, swap_address) < xbl_amount)
            return -1;

        if (ERC20_CALLS.balanceOf(msg.sender) < xbl_amount) 
            return - 2;

        // Reaching this point means we can go ahead and transfer/freeze the funds and save them to the DB.

        ERC20_CALLS.transferFrom(msg.sender, swap_address, xbl_amount);
        if (xbl_amount >= 5000)
        {
            balance = xbl_amount *getPercent(5,xbl_amount);
        }
        else
        {
            balance = xbl_amount;
        }
        registered_for_swap_database[eosio_username] = balance; // Test to see if this can work this way!
        address_to_eosio_username[register_counter] = eosio_username; // Test to see if this can work this way!
        register_counter += 1;
    }
    
    function getEOSIO_USERNAME(uint256 target) public view returns (string memory eosio_username)
     {
        return address_to_eosio_username[target];
     }
     
    function getBalanceByEOSIO_USERNAME(string memory eosio_username) public view returns (uint256 swap_balance) 
     {
        return registered_for_swap_database[eosio_username];
     }
}

// Smart Contrak that will:


// 1. Users must first give allowance for all their XBL (Or however much they want to swap)
// 2. Users will call a function registerSwap(uint256 xbl_amount, string eosio_username) on THIS contrak.
// 3. The contrak will then check if allowance <= xbl_amount.
// 4. If the allowance checks out, the Contrak will then transfer all of the users funds to itself.
// 5. The contrak will create a database entry of the user's eosio username and the amount of XBL it has registered succesfully.
// 6. These funds are now frozen. The database will then be used by the eosio airdrop/XBL swap contrak.

// TODO: 1. Add address_to_eosio_username mapping to the registerSwap function.
//       2. if  balance > 5000, add 5% directly in registerSwap function so it's not payable when we call getBalanceByEOSIO_USERNAME
//       3. See if there's a simpler way to store all of this data by using only one array.


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
    mapping(string => uint256) registered_for_swap_database; // String = eosio_username , uint256 = XBL balance
    mapping(address=> string) address_to_eosio_username; //String = eosio_username, 

    address public swap_address;
    address public XBLContract_addr;
    XBL_ERC20Wrapper private ERC20_CALLS;


    constructor() public
    {
        swap_address = address(this); /* Own address */
        XBLContract_addr = 0xef55BfAc4228981E850936AAf042951F7b146e41;
        ERC20_CALLS = XBL_ERC20Wrapper(XBLContract_addr);
    }
    

    function registerSwap(uint256 xbl_amount, string memory eosio_username) public returns (int256 STATUS_CODE)
    {
        // -1 = allowance mismatch
        // -2 = balance mismatch
        if (ERC20_CALLS.allowance(msg.sender, swap_address) < xbl_amount)
            return -1;

        if (ERC20_CALLS.balanceOf(msg.sender) < xbl_amount) 
            return - 2;

        // Reaching this point means we can go ahead and transfer/freeze the funds and save them to the DB.

        ERC20_CALLS.transferFrom(msg.sender, swap_address, xbl_amount);
        registered_for_swap_database[eosio_username] = xbl_amount;
    }
    
    function getPercent(uint8 percent, uint256 number) private returns (uint256 result)
    {
        return number * percent / 100;
    }
    
    function getEOSIO_USERNAME(address _owner) public view returns (string memory eosio_username) 
     {
        return address_to_eosio_username[_owner];
     }
     
    function getBalanceByEOSIO_USERNAME(string memory eosio_username) public returns (uint256 balance) 
     {
        balance = registered_for_swap_database[eosio_username];
        if (balance > 5000)
        {
            return balance *getPercent(5,balance);
        }
        else
        {
            return balance;    
        }
     }
}

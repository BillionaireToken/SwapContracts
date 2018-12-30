// Smart Contrak that will:


// 1. Users must first give allowance for all their XBL (Or however much they want to swap)
// 2. Users will call a function registerSwap(uint256 xbl_amount, string eosio_username) on THIS contrak.
// 3. The contrak will then check if allowance <= xbl_amount.
// 4. If the allowance checks out, the Contrak will then transfer all of the users funds to itself.
// 5. The contrak will create a database entry of the user's eosio username and the amount of XBL it has registered succesfully.
// 6. These funds are now frozen. The database will then be used by the eosio airdrop/XBL swap contrak.


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
	mapping(string => uint256) public registered_for_swap_database;

	address public swap_address;
	address public XBLContract_addr;

	constructor() public
	{
		swap_address = address(this); /* Own address */
		XBLContract_addr = 0x49AeC0752E68D0282Db544C677f6BA407BA17ED7;
		ERC20_CALLS = XBL_ERC20Wrapper(XBLContract_addr);
	}
	

	function registerSwap(uint256 xbl_amount, string memory eosio_username) public returns (uint256 STATUS_CODE)
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
}

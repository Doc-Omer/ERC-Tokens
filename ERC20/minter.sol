//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
contract main is ERC20{

    constructor(string memory _name, string memory _symbol, uint _decimal, uint _totalSupply) ERC20(_name,_symbol,_decimal,_totalSupply){
        
    }

    function _mint(address account, uint amount) public {
        super.mint(account,amount);
       
       
    }
}
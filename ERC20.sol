//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC.sol";

contract ERC20{

    event Transfer(address sender, address to, uint value);
    event Approval(address owner, address spender, uint value);


    uint public totalSupply;
    string public name;
    string public symbol;
    uint public decimal;
    address public owner;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public  allowances;

    constructor(string memory _name, string memory _symbol, uint _decimal, uint _totalSupply){
        name = _name;
        symbol = _symbol;
        decimal = _decimal;
        owner = msg.sender;
        totalSupply = _totalSupply*decimal;
        balances[msg.sender] = totalSupply;
    }

    modifier  onlyOwner(){
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function transfer(address to, uint amount) external returns(bool){
        require(balances[msg.sender] >= amount, "Amount is less");
        require(to != address(0), "Invalid address");
        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address _owner, address spender) internal view returns (uint){
        return allowances[_owner][spender];
    }
    

    function transferFrom(address from, address to, uint amount) external {
        require(from != address(0), "invalid from address");
        require(to != address(0), "Invalid to address");
        require(balances[from] >= amount, "Amount is less");
        uint _amount = allowance(from, to);
        _amount -= amount;
        balances[from] -= amount;
        balances[to] += amount;
    }

    function approval(address spender, uint value) external returns(bool) {
        require(msg.sender != address(0) || spender != address(0),"Invalid address");
        require(balances[msg.sender] <= value, "do not hav enough value");
        allowances[msg.sender][spender] += value;

        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transfer(address from, address to, uint value)external {
        require(msg.sender != address(0) || to != address(0),"Invalid address");
        require(balances[from] >= value, "no enough value");
        balances[from] -= value;
        balances[to] += value;
    }

    function mint(address account, uint amount)external onlyOwner {
        require(account != address(0), "invalid address");
        balances[account] += amount;
        totalSupply += amount;
    }

    function burn(address account, uint amount)external onlyOwner {
        require(account != address(0), "invalid address");
        balances[account] -= amount;
        totalSupply -= amount;
    }


    
}
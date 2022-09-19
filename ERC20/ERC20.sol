//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/utils/Context.sol";

contract ERC20 is Context{

    using SafeMath for uint;
    //using Context for address;

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
        owner = super._msgSender();
        totalSupply = totalSupply.mul(_totalSupply*decimal);
        balances[msg.sender] = totalSupply;
    }

    modifier  onlyOwner(){
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function transfer(address to, uint amount) internal returns(bool){
        require(balances[msg.sender] >= amount, "Amount is less");
        require(to != address(0), "Invalid address");
        balances[msg.sender] =balances[msg.sender].sub(amount);
        balances[to] += balances[to].sub(amount);

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address _owner, address spender) internal view returns (uint){
        return allowances[_owner][spender];
    }
    

    function transferFrom(address from, address to, uint amount) internal {
        require(from != address(0), "invalid from address");
        require(to != address(0), "Invalid to address");
        require(balances[from] >= amount, "Amount is less");
        uint _amount = allowance(from, to);
        _amount = _amount.sub(amount);
        balances[from] = balances[from].sub(amount);
        balances[to] = balances[to].add(amount);
    }

    function approval(address spender, uint value) internal returns(bool) {
        require(msg.sender != address(0) || spender != address(0),"Invalid address");
        require(balances[msg.sender] <= value, "do not hav enough value");
        allowances[msg.sender][spender] = allowances[msg.sender][spender].add(value);

        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transfer(address from, address to, uint value)internal {
        require(msg.sender != address(0) || to != address(0),"Invalid address");
        require(balances[from] >= value, "no enough value");
        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
    }

    function mint(address account, uint amount) internal  {
        require(account != address(0), "invalid address");
        balances[account] = balances[account].add(amount);
        totalSupply = totalSupply.add(amount);
    }

    function burn(address account, uint amount)internal onlyOwner {
        require(account != address(0), "invalid address");
        balances[account] = balances[account].sub(amount);
        totalSupply = totalSupply.sub(amount);
    }
}


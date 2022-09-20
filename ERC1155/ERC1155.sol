//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract ERC1155 is Context{

    using SafeMath for uint;

    event TransferSingle(address operator, address from, address to,uint id, uint value);
    event TransferBatch(address operator, address from, address to, uint id, uint value);
    event ApprovalForAll(address account, address operator, bool approved);

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;


    //sets the URI during deployment
    constructor(string memory uri_){
        _uri = uri_;
       
    }

    function balanceOf(address account, uint id) public view returns(uint) {
        //returns the amount of token of token type ID owned by the account
        require(account != address(0), "Address is 0");
        return _balances[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint[] memory ids) external view returns(uint[] memory) {
        //returns the amount of token of tokens type IDs owned by the accounts
        require(accounts.length == ids.length, "Length of accounts and ids are not equal");
        uint[] memory batchedBalance;
        for(uint i = 0; i < accounts.length; i++){
            batchedBalance[i] = balanceOf(accounts[i], ids[i]);
        }
        return batchedBalance;
    }

    function setApprovalForAll(address operator, bool approved) external returns(bool) {
        //grants or revokes the permission to "operator" to transfer the caller's tokens, according to approved 
        require(super._msgSender() != operator || operator != address(0), "Either msg.sender == operator or operator address is 0");
        _operatorApprovals[super._msgSender()][operator] = approved;

        emit ApprovalForAll(super._msgSender(), operator, approved);
        return true;
    }

    function isApprovedForAll(address account, address operator) public view returns(bool) {
        //returns true if operator is apporved to transfer accounts tokens.
        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(address from, address to, uint id, uint amount) public {
        //  transfers amount tokens of token type 'id' from 'from' to 'to'
        require(from != address(0) || to != address(0), "either from address is 0 or to address is 0");
        require(_balances[id][from] >= amount, "Balance less than amount");
        require(super._msgSender() == from || isApprovedForAll(from, super._msgSender()) == true, "Caller is not the owner of the token or is not approved");

        _balances[id][from] = _balances[id][from].sub(amount);
        _balances[id][to] = _balances[id][to].add(amount);

        emit TransferSingle(super._msgSender(), from, to, id, amount);
    }

    function safeBatchTransferFrom(address from, address to, uint[] memory ids, uint[] memory amounts) external returns(bool) {
        //batched version of safeTransferFrom
        require(ids.length == amounts.length, "number of ids and amounts are not equal");

        for(uint i = 0; i < ids.length; i++){
            safeTransferFrom(from, to, ids[i], amounts[i]);
        }
        return true;
    }

    function mint(address to, uint id, uint amount) public {
        //mints the 'amount' of token type 'id' assigns them to 'to'
        require(to != address(0), "to address is 0");
        _balances[id][to] = _balances[id][to].add(amount);

        emit TransferSingle(super._msgSender(), address(0), to, id, amount);
    }

    function mintBatch(address to, uint[] memory ids, uint[] memory amounts) public returns (bool){
        //batch version of mint
        require(ids.length == amounts.length, "number of ids and amounts are not equal");
        for(uint i = 0; i < ids.length; i++){
            mint(to, ids[i], amounts[i]);
        }
        return true;
    }

    function burn(address from, uint id, uint amount) public {
        //destroys 'amount' tokens of type 'id' from 'from'
        require(from != address(0), "Address is 0");
        require(_balances[id][from] <= amount, "Amount is greater than actual");
        _balances[id][from] = _balances[id][from].sub(amount);

        emit TransferSingle(super._msgSender(), from, address(0), id, amount);
    }

    function burnBatch(address from, uint[] memory ids, uint[] memory amount) public returns(bool){
        //batched version of burn
        require(ids.length == amount.length, "number of ids and amounts are not equal");
        for(uint i = 0; i < ids.length; i++){
            burn(from, ids[i], amount[i]);
        }
        return true;
    }


}
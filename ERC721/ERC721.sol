//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/utils/Strings.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/utils/Context.sol";


contract ERC721 is Context{
    using Strings for uint256;
    using SafeMath for uint256;

    event Transfer(address from, address to, uint tokenId);
    event Approval(address owner, bool approved, uint tokenId);
    event ApprovalForAll(address owner, address operator, bool approved);

    string public name;
    string public symbol;
    address public ownerofcontract;

    mapping(uint => address) private owners; //token ID to owner
    mapping(address => uint) private balances; //owner k address se token count
    mapping(uint => address) private tokenApprovals; //token ID to approved address
    mapping(address => mapping(address => bool)) private operatorApprovals;

    constructor(string memory _name, string memory _symbol){
        name = _name;
        symbol = _symbol;
        ownerofcontract = super._msgSender();
    }

    function balanceOf(address _owner) external view returns(uint){
        //returns you the balance of the address
        require(_owner != address(0), "Address does not exist");
        return balances[_owner];
    }

    function ownerOf(uint _id) external view returns (address){
        //return the address of the tokenID
        require(owners[_id] != address(0), "Token ID does not exist");
        return owners[_id];
    }

    function isApprovedForAll(address owner, address operator)  public view returns(bool){
        //returns if the address is approved or not in boolean
        return operatorApprovals[owner][operator];
    }

    function setApprovalForAll(address operator, bool _approved) external {
        //set the approval for an address
        require(operator != super._msgSender(), "The operator is owner");
        operatorApprovals[super._msgSender()][operator] = _approved;
    }

    function getApproved(uint tokenId) external view returns(address) {
        //returns which account is approved for the token id
        require(tokenApprovals[tokenId] != address(0), "Token ID does not exist");
        return tokenApprovals[tokenId];
    }

    function transferFrom(address from, address to, uint tokenId) public returns(bool) {
        //transfers the ownership from "from" to "to"
        require(from != address(0) , "from address DNE");
        require(to != address(0), "To address DNE");
        require(owners[tokenId] == from, "from is not the owner of this token");
        if(super._msgSender() != from){
            if(tokenApprovals[tokenId] == super._msgSender()){
                owners[tokenId] = to;
                return true;
            }
            return false;
        }
        owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
        return true;
    }

    function approve(address to, uint tokenId) public {
        //approves another owner to be spend the token on behalf of the owner
        require(super._msgSender() == owners[tokenId] || tokenApprovals[tokenId] == super._msgSender(), "msg.sender do not own the token");
        require(to != address(0), "Invalid address");
        require(owners[tokenId]  != address(0), "Token ID does not exist");
        operatorApprovals[super._msgSender()][to] = true;
        tokenApprovals[tokenId] = to;
    }

    function safeTransferFrom(address from, address to, uint tokenId) external returns (bool){
        //
        require(from != address(0), "Invalid address");
        require(to != address(0), "Invalid address");
        require(owners[tokenId] == from && owners[tokenId] != address(0), "Token Id does not exist");

        if(super._msgSender() != from){
            if(tokenApprovals[tokenId] == super._msgSender()){
                owners[tokenId] = to;
                return true;
            }
            else return false;
        }
        transferFrom(from,to, tokenId);

        emit Transfer(from, to, tokenId);
        return true;
    }

    function _baseURI(uint tokenId) internal view returns(string memory){
        require(owners[tokenId] != address(0), "Address is 0");

        return bytes(baseURI()).length > 0 ? string(abi.encodePacked(baseURI(), tokenId.toString())) : "";
    }

    function baseURI() internal view virtual returns (string memory) {
        return "";
    }

}
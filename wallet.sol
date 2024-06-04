// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20; 

contract wallet {

    address payable private _owner;
    
    struct walletr {
        uint balance;
        uint numberOfPayments;
    }

    mapping(address => walletr) wallets;

    constructor(address payable owner) {
        _owner = owner;
    }

    receive() external payable { 
        wallets[msg.sender].balance += msg.value;
        wallets[msg.sender].numberOfPayments += 1;
    }

    function getTotalBalance() public view returns(uint) {
        return address(this).balance;
    }

    function getBalance() public view returns(uint) {
        return wallets[msg.sender].balance;
    }

    function transfer() public {
        address payable _to = payable(msg.sender);
        uint _amount = wallets[_to].balance;
        require(wallets[_to].balance > 0, "Erreur Balance 0");
        _to.transfer(_amount);
        wallets[_to].balance = 0;
    }

     function isOwner() public view returns(bool)  { 
        return msg.sender == _owner; 
    } 

    function transferAllToOwner() public { 
        require(isOwner(),
        "Function accessible only by the owner !!");
        _owner.transfer(address(this).balance);
    }
}

pragma solidity ^0.4.21;

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(
        address indexed _from, 
        address indexed _to
    );

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) onlyOwner public {
        newOwner = _newOwner;
    }
    
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }    
}
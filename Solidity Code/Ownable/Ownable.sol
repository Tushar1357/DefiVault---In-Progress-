// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

abstract contract Ownable {
    address private owner;
    event OwnershipTransferred(
        address indexed oldOwner,
        address indexed newOwner
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function getowner() public view returns (address) {
        return owner;
    }

    function transferOwnership(address newOwner)
        public
        onlyOwner
        returns (bool)
    {
        address oldOwner = getowner();
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
        return true;
    }
}

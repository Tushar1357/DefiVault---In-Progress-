// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./Ownable.sol";

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

contract Lend is Ownable {
    mapping(address => uint256) private amountDeposit;
    uint256 private totalAmountDeposited;
    mapping(address => uint256) private lastDate;
    address[] public tokensAccepted = [
        0x545C1aFBdF28b67F06c47Af6803ea4E87f507155
    ];

    event Deposited(
        address indexed lender,
        address indexed tokenAddress,
        uint256 indexed amountDeposited
    );
    event Withdrawal(
        address indexed lender,
        address indexed tokenAddress,
        uint256 amountDeposited
    );

    modifier allowed(address lender, uint256 timestamp) {
        require(lastDate[lender] <= timestamp, "You cannot withdraw for now");
        _;
    }

    function checkToken(address tokenAddress) public view returns (bool) {
        uint256 i = 0;
        uint256 j = tokensAccepted.length - 1;
        while (i <= j) {
            if (
                tokensAccepted[i] == tokenAddress ||
                tokensAccepted[j] == tokenAddress
            ) return true;
            i++;
            j--;
        }
        return false;
    }

    function getShare(address lender) public view returns (uint256) {
        uint256 precision = 1e9;
        return (amountDeposit[lender] * precision) / totalAmountDeposited;
    }

    function depositFunds(address tokenAddress, uint256 amount)
        external
        returns (bool)
    {
        require(checkToken(tokenAddress), "Invalid token address");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        totalAmountDeposited += amount;
        amountDeposit[msg.sender] += amount;
        lastDate[msg.sender] = block.timestamp + 60 * 60 * 24 * 30 * 3;
        emit Deposited(msg.sender, tokenAddress, amount);
        return true;
    }

    function withdrawFunds(address tokenAddress, uint256 amount)
        external
        allowed(msg.sender, block.timestamp)
        returns (bool)
    {
        require(amountDeposit[msg.sender] >= amount, "Insufficient balance");
        amountDeposit[msg.sender] -= amount;
        totalAmountDeposited -= amount;
        IERC20(tokenAddress).transfer(msg.sender, amount);
        emit Withdrawal(msg.sender, tokenAddress, amount);
        return true;
    }

    function addToken(address tokenAddress) external onlyOwner {
        tokensAccepted.push(tokenAddress);
    }

    function removeToken(address tokenAddress) external onlyOwner {
        require(checkToken(tokenAddress), "Invalid token");

        for (uint256 i = 0; i < tokensAccepted.length; i++) {
            if (tokensAccepted[i] == tokenAddress) {
                tokensAccepted[i] = tokensAccepted[tokensAccepted.length - 1];
                tokensAccepted.pop();
                break;
            }
        }
    }

    function getLenderBalance(address lender)
        public 
        view
        returns (uint256)
    {
        return amountDeposit[lender];
    }
}

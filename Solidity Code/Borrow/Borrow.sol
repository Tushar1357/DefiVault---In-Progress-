// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./Ownable.sol";
import "./Interest.sol";


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

contract Borrow is Ownable,InterestRate {
    address public collateralAccepted =
        0x545C1aFBdF28b67F06c47Af6803ea4E87f507155;

    mapping(address => uint256) LoanTaken;
    
    uint256 private totalAmountBorrowed = 0;

    mapping(address => uint256) LiquidationDate;

    mapping(address => bool) blackListed;

    
    uint256 private collateralPrice = 2500;

    mapping(address => uint256) lastRepaymentTime;

    mapping(address => uint256) borrowTime;

    event Borrowed(
        address indexed borrower,
        address indexed tokenAddress,
        address indexed amountBorrowed
    );
    event Repayed(
        address indexed borrower,
        address indexed tokenAddress,
        address indexed amountRepayed
    );

    modifier checkCollateral(address tokenAddress) {
        require(
            collateralsAccepted == tokenAddress,
            "This cannot be accepted as a collateral"
        );
        _;
    }

    modifier checkBlacklist(address borrower){
        require(blackListed[borrower],"Borrower is blacklisted from taking Loans");
        _;
    }

    modifier checkLastBorrowed(address borrower, uint256 timestamp){
        require(lastRepaymentTime[borrower] <= timestamp,"You cannot borrow more until repayment of previous loan");
    }

    function getCollateralPrice() public view returns (uint256) {
        return collateralPrice;
    }

    function updateCollateralPrice(uint256 price) external onlyOwner {
        collateralPrice = price;
    }

    function borrowAmount(
        address collateralAddress,
        uint256 collateralAmount,
        uint256 amount
    ) external checkCollateral(collateralAddress) checkBlacklist(msg.sender) checkLastBorrowed(msg.sender, block.timestamp) returns (bool) {
        uint256 nativetokenAmount = getCollateralPrice() * collateralAmount;
        require(nativetokenAmount > amount,"Collateral amount is less than the loan amount");
        IERC20(collateralAddress).transferFrom(msg.sender,address(this),collateralAmount);
        IERC20.(tokenAddress).transfer(msg.sender,amount);
        borrowTime[msg.sender] = block.timestamp;
        return true;
    }

    function RepayAmount(
        uint256 amount
    ) external returns (bool){
        uint currentTimeStamp = (block.timestamp > lastRepaymentTime[msg.sender]) ? lastRepaymentTime[msg.sender]: block.timestamp;
        uint256 InterestAmount = getLoanInterestAmount(borrowTime[msg.sender],amountBorrowed[msg.sender],currentTimeStamp);
        require(LoanTaken[msg.sender] >= amount + InterestAmount,"You are paying more than the loan taken");
        return true;
    }
}

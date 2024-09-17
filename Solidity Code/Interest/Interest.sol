// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./Ownable.sol";

contract InterestRate is Ownable{
    uint private LendIntRate;
    uint private BorrowIntRate;

    event InterestRateChanged(uint indexed oldRate, uint indexed newRate);

    constructor(uint lendrate,uint borrowrate){
        LendIntRate = lendrate;
        BorrowIntRate = borrowrate;
    }

    function getCurrentLendRate() view public returns (uint){
        return LendIntRate;
    }

    function getCurrentBorrowRate() view public returns (uint){
        return BorrowIntRate;
    }

    function getCurrentLendRateInSec() view public returns(uint){
        return (LendIntRate * 10e9) / (3 * 30 * 24 * 60 * 60); 
    }

    function getCurrentBorrowRateInSec() view public returns(uint){
        return (BorrowIntRate * 10e9) / (3 * 30 * 24 * 60 * 60); 
    }

    function getLendInterestAmount(uint initalTimeStamp, uint256 lendAmount,uint currentTimeStamp) view public returns(uint256){
        uint256 amount = getCurrentLendRateInSec() * (currentTimeStamp - initalTimeStamp) * lendAmount;
        return amount / 100;
    }

    function getLoanInterestAmount(uint initalTimeStamp, uint256 borrowedAmount,uint currentTimeStamp) view public returns(uint256){
        uint256 amount = getCurrentBorrRateInSec() * (currentTimeStamp - initalTimeStamp) * borrowedAmount;
        return amount / 100;
    }

    function changeCurrentLendRate(uint newRate) external onlyOwner{
        uint oldRate = getCurrentLendRate();
        LendIntRate = newRate;
        emit InterestRateChanged(oldRate, newRate);
    }

    function changeCurrentBorrowRate(uint newRate) external onlyOwner{
        uint oldRate = getCurrentBorrowRate();
        BorrowIntRate = newRate;
        emit InterestRateChanged(oldRate, newRate);
    }

}
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
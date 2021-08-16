// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PoolHelper is Ownable {

    using SafeMath for uint256;
    using SafeMath for uint64;

    uint16 distributeTime  = 480; // 8 hours

    function setDistributeTime(uint8 _distributeTime) public onlyOwner{
        distributeTime = _distributeTime;
    }

    function calculateReward(uint256 _totalFee,uint256 _amount,uint256 _totalStake,uint64 _stakeTime) public returns(uint256){
        uint256 freePerUnit = _totalFee.div(_totalStake);
        uint256 reward = freePerUnit.mul(_amount);
        uint256 rewardPerMinutes = reward.div(480);
        uint256 timeToStake = uint64(block.timestamp).sub(_stakeTime).div(60);
        uint256 finalReward = rewardPerMinutes.mul(timeToStake);
        return finalReward;
    }
}

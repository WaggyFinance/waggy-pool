// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./PoolHelper.sol";

contract pool is Ownable {

    using SafeMath for uint256;
    using SafeMath for uint64;

    struct ownerAccount {
        uint amount;
        uint64 lastModified;
        uint256 reward;
    }

    PoolHelper poolHelper;
    address[]  stakeOwners;
    uint256 totalStake;

    ERC20 WAG;
    ERC20 FEE;
    mapping(address => ownerAccount) depositOwner;

    constructor(address _wag, address _fee)  {
        WAG = ERC20(_wag);
        FEE = ERC20(_fee);
    }

    function setPoolHelper(address _poolHelper) public onlyOwner {
        poolHelper = PoolHelper(_poolHelper);
    }

    function distributeReward() external {
        uint256 totalFee = FEE.balanceOf(address(this));
        if (totalFee > 0) {
            for (uint i = 0; i < stakeOwners.length; i++) {
                ownerAccount memory account = depositOwner[stakeOwners[i]];
                if (account.amount > 0) {
                    uint256 reward = poolHelper.calculateReward(totalFee, account.amount, totalStake, account.lastModified);
                    depositOwner[stakeOwners[i]].reward = depositOwner[stakeOwners[i]].reward.add(reward);
                }
            }
        }
    }

    function deposit(uint256 _amount) public payable {
        require(_amount > 0, "Not allow 0");
        require(WAG.transferFrom(msg.sender, address(this), _amount), "Can't deposit WAG");
        claimReward(msg.sender);
        totalStake = totalStake.add(_amount);

        if (depositOwner[msg.sender].lastModified == 0) {
            stakeOwners.push(address(msg.sender));
        }

        depositOwner[msg.sender].amount = depositOwner[msg.sender].amount.add(_amount);
        depositOwner[msg.sender].lastModified = uint64(block.timestamp);
        depositOwner[msg.sender].reward = 0;
    }

    function getOwnerBalance() public view returns (uint256 balance){
        balance = depositOwner[msg.sender].amount;
    }

    function withdraw(uint _amount) public payable {
        require(depositOwner[msg.sender].amount >= _amount, "Balance not enough to with draw");
        require(WAG.transfer(msg.sender, _amount), "Can't withdraw WAG");
        claimReward(msg.sender);
        totalStake = totalStake.sub(_amount);
        depositOwner[msg.sender].amount = depositOwner[msg.sender].amount.sub(_amount);
        depositOwner[msg.sender].lastModified = uint64(block.timestamp);
        depositOwner[msg.sender].reward = 0;
    }

    function getReward(address _address) public view returns (uint256) {
        return depositOwner[msg.sender].reward;
    }

    function claimReward(address _address) public {
        uint256 reward = getReward(_address);
        if (reward > 0) {
            FEE.transfer(msg.sender, reward);
            depositOwner[msg.sender].reward = 0;
        }
    }
}

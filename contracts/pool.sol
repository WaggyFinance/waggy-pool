// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract pool {

    using SafeMath for uint256;

    struct ownerAccount {
        uint amount;
        uint lastModified;
    }

    ERC20 WAG;
    ERC20 FEE;
    mapping(address => ownerAccount) depositOwner;

    constructor(address _wag)  {
        WAG = ERC20(_wag);
    }

    function deposit(uint256 _amount) public payable {
        require(_amount > 0, "Not allow 0");
        require(WAG.transferFrom(msg.sender, address(this), _amount), "Can't deposit WAG");
        //        claimReward();
        depositOwner[msg.sender].amount = depositOwner[msg.sender].amount.add(_amount);
        depositOwner[msg.sender].lastModified = block.timestamp;
    }

    function getOwnerBalance() public returns(uint256 balance){
        balance = depositOwner[msg.sender].amount;
    }

    function withdraw(uint _amount) public payable {
        require(depositOwner[msg.sender].amount >= _amount, "Balance not enough to with draw");
        require(WAG.transfer(msg.sender, _amount), "Can't withdraw WAG");
        //        claimReward();
        depositOwner[msg.sender].amount = depositOwner[msg.sender].amount.sub(_amount);
        depositOwner[msg.sender].lastModified = block.timestamp;
    }

    function getReward(address _address) public returns (uint256 rewards) {
        uint256 totalDeposit = WAG.balanceOf(_address);
        uint256 totalFee = FEE.balanceOf(address(this));
        rewards = totalFee.mod(totalDeposit).mul(depositOwner[_address].amount);
    }

    function claimReward() public {
        uint256 reward = getReward(msg.sender);
        uint256 percent = (block.timestamp - depositOwner[msg.sender].lastModified) % 8 hours;
        uint256 finalReward = reward.mul(percent);
        FEE.transfer(msg.sender, finalReward);
    }
}

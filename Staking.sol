// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IERC20.sol";

contract Staking {

IERC20 private token;

    struct Stake {
        address tokenAddress;
        address staker;
        uint amount;
        uint stakingPeriod;
        uint startTime;
    }

    event Staked(Stake stake, uint256 amount);
    event Withdrawn(address indexed staker, uint256 amount);

    mapping (address => Stake) public stakes;
    address public staker;

    constructor(address _tokenAddress) {
        staker = msg.sender;
        token = IERC20(_tokenAddress);
    }

    function stakeTokens(address tokenAddress, uint256 _amount, uint256 stakingPeriod) external {
        require (msg.sender != address(0), "address zero cannot stake");

        require (_amount > 0, "zero cannot be staked.");

        require (stakingPeriod > 0, "input a valid staking period.");

        require (token.transferFrom(msg.sender, address(this), _amount), "failed to transfer");

        stakes[msg.sender] = Stake({
            tokenAddress: tokenAddress,
            staker: staker,
            startTime : block.timestamp,
            amount : _amount,
            stakingPeriod : stakingPeriod
        });

         emit Staked(stakes[msg.sender],  _amount);
    
    }

    function withdraw() external {
        require (msg.sender == staker, "You don't have any stakes.");

        require (stakes[msg.sender].startTime + stakes[msg.sender].stakingPeriod >= block.timestamp, "Staking Period Not Elapsed");

        uint256 _amount = stakes[msg.sender].amount;
        
        token.transferFrom(address(this), msg.sender, _amount);

        emit Withdrawn(msg.sender, _amount);

    }
}

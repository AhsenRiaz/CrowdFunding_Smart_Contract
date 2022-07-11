// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "./IERC20.sol";
import "./iCF.sol";


contract Crowdfunding is ICF {

    IERC20 private _token;

    struct Campaign {
        address creator;
        uint goal;
        uint pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
    }

    Campaign[] private _campaigns;

    mapping(uint => mapping(address => uint)) private _pledgedAmount;

    constructor(address token_){
        _token = IERC20(token_);
    }

    function launch(uint goal_ ) external {
        require(msg.sender != address(0) , "invalid address");
        _campaigns.push(Campaign({
            creator: msg.sender,
            goal : goal_,
            pledged: 0,
            startAt: block.timestamp + 60,
            endAt: startAt + 180,
            claimed : false
        }));
    }

    function pledge(uint id , uint _amount) external {
        require(id < campaigns.length , "invalid id");
        require(amount > 0 , "amount < 0");

        Campaign storage campaign = _campaigns[id];

        require(block.timestamp > campaign.startAt , "not started");
        require(block.timestamp < campaign.endAt , "ended");

        campaign.pledged += amount;
        _pledgedAmount[id][msg.sender] += amount;
        _token.transfer( address(this) , _amount);
    }

    function unpledge(uint id , uint amount) external {
        require(id < campaigns.length , "invalid id");
        require(amount <= _pledgedAmount[_id][msg.sender] , "amount > pledged");

        Campaign storage campaign = _campaigns[id];
        require(block.timestamp > campaign.startAt , "not started");
        require(block.timestamp < campaign.endAt , "ended");

        campaign.pledged += amount;
        _pledgedAmount[id][msg.sender] += amount;
        _token.transfer(msg.sender , _amount);

    }
    
    function claim(uint id) external {
        require(id < campaigns.length , "invalid id");

        Campaign storage campaign = _campaigns[id];

        require(!campaign.claimed , "claimed");
        require(block.timestamp > _endAt , "not ended");
        require(campaign.pledged >= campaign.goal , "pledged < goal");

        claimed = true;

        _token.transfer(_owner , campaign.pledged);
    }

    function refund(uint id) external {
         Campaign storage campaign = _campaigns[id];

        require(campaign.pledged < campaign.goal , "goal > pledged");

        uint bal = _pledgedAmount[id][msg.sender];
        _pledgedAmount[id][msg.sender] = 0;
        _token.transfer(msg.sender , bal);

        
    }

}
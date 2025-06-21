// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PredictionMarket {
    address public owner;
    string public eventDescription;
    bool public outcomeSet;
    uint8 public outcome; // 0 = Not decided, 1 = Yes, 2 = No

    mapping(address => uint256) public yesBets;
    mapping(address => uint256) public noBets;
    uint256 public totalYes;
    uint256 public totalNo;

    constructor(string memory _description) {
        owner = msg.sender;
        eventDescription = _description;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    modifier outcomeNotSet() {
        require(!outcomeSet, "Outcome already set");
        _;
    }

    function placeBet(bool prediction) external payable outcomeNotSet {
        require(msg.value > 0, "Must bet some ETH");
        if (prediction) {
            yesBets[msg.sender] += msg.value;
            totalYes += msg.value;
        } else {
            noBets[msg.sender] += msg.value;
            totalNo += msg.value;
        }
    }

    function setOutcome(uint8 _outcome) external onlyOwner outcomeNotSet {
        require(_outcome == 1 || _outcome == 2, "Invalid outcome");
        outcome = _outcome;
        outcomeSet = true;
    }

    function claimReward() external {
        require(outcomeSet, "Outcome not set yet");
        uint256 reward;
        if (outcome == 1 && yesBets[msg.sender] > 0) {
            reward = address(this).balance * yesBets[msg.sender] / totalYes;
            yesBets[msg.sender] = 0;
        } else if (outcome == 2 && noBets[msg.sender] > 0) {
            reward = address(this).balance * noBets[msg.sender] / totalNo;
            noBets[msg.sender] = 0;
        }
        require(reward > 0, "No reward available");
        payable(msg.sender).transfer(reward);
    }
}

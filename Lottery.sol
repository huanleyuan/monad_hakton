// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public owner;
    address[] public players;
    uint256 public ticketPrice;
    bool public isActive;
    
    event PlayerEntered(address player);
    event WinnerSelected(address winner, uint256 amount);
    
    constructor(uint256 _ticketPrice) {
        owner = msg.sender;
        ticketPrice = _ticketPrice;
        isActive = true;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    modifier lotteryActive() {
        require(isActive, "Lottery not active");
        _;
    }
    
    function enter() external payable lotteryActive {
        require(msg.value == ticketPrice, "Incorrect ticket price");
        players.push(msg.sender);
        emit PlayerEntered(msg.sender);
    }
    
    function drawWinner() external onlyOwner lotteryActive {
        require(players.length > 0, "No players");
        
        uint256 winnerIndex = uint256(keccak256(abi.encodePacked(
            block.timestamp, 
            block.difficulty, 
            players
        ))) % players.length;
        
        address winner = players[winnerIndex];
        uint256 prize = address(this).balance;
        
        // Reset lottery
        delete players;
        isActive = false;
        
        payable(winner).transfer(prize);
        emit WinnerSelected(winner, prize);
    }
    
    function startNewLottery() external onlyOwner {
        require(!isActive, "Lottery already active");
        isActive = true;
    }
    
    function getPlayers() external view returns (address[] memory) {
        return players;
    }
    
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
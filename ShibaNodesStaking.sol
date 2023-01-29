pragma solidity ^0.8.0;

contract SHINOSTAKING {
    address payable public owner;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public rewards;
    mapping(address => bool) public canWithdraw;
    ERC20 public token = 0x512Ef73caAFF561719D611289807Ce93CE652805;
    uint256 public depositBlock;

    constructor(address _tokenAddress) public {
        owner = msg.sender;
        token = ERC20(_tokenAddress);
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than zero.");
        require(msg.sender != owner, "Owner cannot deposit.");
        require(token.transferFrom(msg.sender, address(this), msg.value), "Token transfer failed.");
        deposits[msg.sender] = deposits[msg.sender].add(msg.value);
        depositBlock = block.timestamp;
        canWithdraw[msg.sender] = false;
    }

    function withdraw() public {
        require(canWithdraw[msg.sender], "Cannot withdraw before lock period has ended.");
        require(msg.sender != owner, "Owner cannot withdraw.");
        require(rewards[msg.sender] > 0, "No rewards to withdraw.");
        msg.sender.transfer(rewards[msg.sender]);
        rewards[msg.sender] = 0;
    }

    function release() public {
        require(msg.sender == owner, "Only owner can release funds.");
        for (address user in canWithdraw) {
            canWithdraw[user] = true;
        }
    }

    function reward() public {
        require(msg.sender == owner, "Only owner can reward depositors.");
        for (address user in deposits) {
            rewards[user] = rewards[user].add(deposits[user].mul(2));
        }
    }
}

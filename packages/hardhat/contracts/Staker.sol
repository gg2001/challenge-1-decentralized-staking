pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  mapping (address => uint256) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = now + 1 days;

  event Stake(address indexed sender, uint256 value);

  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable {
    require(now < deadline, "Deadline over");
    
    balances[msg.sender] += msg.value;

    emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public {
    require(now >= deadline, "Wait until the deadline");
    require(address(this).balance >= threshold, "Threshold not met");
    require(!exampleExternalContract.completed(), "Already completed");

    exampleExternalContract.complete{value: address(this).balance}();
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw(address payable withdrawTo) public {
    require(now >= deadline, "Wait until the deadline");
    if (!exampleExternalContract.completed()) {
      require(address(this).balance < threshold, "Threshold met");
    }

    withdrawTo.transfer(balances[withdrawTo]);
    balances[withdrawTo] = 0;
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    if (now >= deadline) {
      return 0;
    } else {
      return deadline - now;
    }
  }
}

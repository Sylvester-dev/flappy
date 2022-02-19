// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "hardhat/console.sol";

contract Domains{

  // A "mapping" data type to store their names
  mapping(string => address) domains;

  constructor(){
    console.log("Hey its my domain :)");
  }

  function register(string calldata name) public{
    domains[name] = msg.sender;
    console.log("%s has registered a name",msg.sender);
  }

  function getAddress(string calldata name) public view returns(address){
    return domains[name];
  }
}


// memory (whose lifetime is limited to a function call)
// storage (the location where the state variables are stored)
// calldata (this indicates the “location” of where the name argument should be stored.it takes the least amount of gas!)
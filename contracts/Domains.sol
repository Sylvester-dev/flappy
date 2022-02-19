// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "hardhat/console.sol";

contract Domains{

  // A "mapping" data type to store their names
  mapping(string => address) domains;
  // This will store values
  mapping(string => string) musics;

  constructor(){
    console.log("Hey its my domain :)");
  }

  function register(string calldata name) public{
    require(domains[name]==address(0));  //to check domain name is unregistered as if a domain hasn’t been registered, it’ll point to the zero address!
    domains[name] = msg.sender;
    console.log("%s has registered a name",msg.sender);
  }

  function getAddress(string calldata name) public view returns(address){
    return domains[name]; // Check that the owner is the transaction sender
  } 

  function setMusic(string calldata name, string calldata music) public {
    require(domains[name]==msg.sender, "You are not the owner of domain"); //checking transaction is done by owner
    musics[name] = music;
  }

  function getMusic(string calldata name) public view returns(string memory){
    return musics[name];
  }
}


// memory (whose lifetime is limited to a function call)
// storage (the location where the state variables are stored)
// calldata (this indicates the “location” of where the name argument should be stored.it takes the least amount of gas!)
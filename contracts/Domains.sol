// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "hardhat/console.sol";
import { StringUtils } from "../libraries/StringUtils.sol";
import {Base64} from "../libraries/Base64.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Domains is ERC721URIStorage{

  address payable public owner;

 //to keep track of tokenIds.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  //setting our domain tld
  string public tld;

  // We'll be storing our NFT images on chain as SVGs
  string svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none"><path fill="url(#a)" d="M0 0h270v270H0z"/><defs><filter id="b" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><path d="M72.863 42.949a4.382 4.382 0 0 0-4.394 0l-10.081 6.032-6.85 3.934-10.081 6.032a4.382 4.382 0 0 1-4.394 0l-8.013-4.721a4.52 4.52 0 0 1-1.589-1.616 4.54 4.54 0 0 1-.608-2.187v-9.31a4.27 4.27 0 0 1 .572-2.208 4.25 4.25 0 0 1 1.625-1.595l7.884-4.59a4.382 4.382 0 0 1 4.394 0l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616 4.54 4.54 0 0 1 .608 2.187v6.032l6.85-4.065v-6.032a4.27 4.27 0 0 0-.572-2.208 4.25 4.25 0 0 0-1.625-1.595L41.456 24.59a4.382 4.382 0 0 0-4.394 0l-14.864 8.655a4.25 4.25 0 0 0-1.625 1.595 4.273 4.273 0 0 0-.572 2.208v17.441a4.29 4.29 0 0 0 .572 2.208 4.25 4.25 0 0 0 1.625 1.595l14.864 8.655a4.382 4.382 0 0 0 4.394 0l10.081-5.901 6.85-4.065 10.081-5.901a4.382 4.382 0 0 1 4.394 0l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616 4.54 4.54 0 0 1 .608 2.187v9.311a4.27 4.27 0 0 1-.572 2.208 4.25 4.25 0 0 1-1.625 1.595l-7.884 4.721a4.382 4.382 0 0 1-4.394 0l-7.884-4.59a4.52 4.52 0 0 1-1.589-1.616 4.53 4.53 0 0 1-.608-2.187v-6.032l-6.85 4.065v6.032a4.27 4.27 0 0 0 .572 2.208 4.25 4.25 0 0 0 1.625 1.595l14.864 8.655a4.382 4.382 0 0 0 4.394 0l14.864-8.655a4.545 4.545 0 0 0 2.198-3.803V55.538a4.27 4.27 0 0 0-.572-2.208 4.25 4.25 0 0 0-1.625-1.595l-14.993-8.786z" fill="#fff"/><defs><linearGradient id="a" x1="0" y1="0" x2="170" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#cb5eee"/><stop offset="1" stop-color="#0c7e4" stop-opacity=".99"/></linearGradient></defs><text x="70" y="231" font-size="20" fill="#fff" filter="url(#b)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
  string svgPartTwo = '</text></svg>';

  // A "mapping" data type to store their names
  mapping(string => address) public domains;
  // This will store values
  mapping(string => string) public musics;
  // Getting names from token_id
  mapping (uint => string) public names;

  constructor(string memory _tld) ERC721("Flappy Naming Service", "FLP") payable{
    owner = payable(msg.sender);
    tld = _tld;
    console.log("%s name service deployed", _tld);
  }
 
 //handling custom made error and Saving Gas :)
  error Unauthorized();
  error AlreadyRegistered();
  error InvalidName(string name);

//function to calculate price of domain based on length
  function price(string calldata name) pure public returns(uint){
   uint len = StringUtils.strlen(name); //This function converts string to bytes first, making it much more gas efficient! 
   require(len > 0, "Domain name too small");
   if(len == 3){
     return 5 * 10**17;  //0.5 matic
   }else if(len == 4){
     return 3 * 10**17;
   }else{
     return 1 * 10**17;
   }
  }

  function register(string calldata name) public payable{
    if(domains[name]!=address(0)) revert AlreadyRegistered();  //to check domain name is unregistered as if a domain hasn’t been registered, it’ll point to the zero address!
    if (!valid(name)) revert InvalidName(name);

    uint _price = this.price(name);
    require(msg.value >= _price , "Not enough MATIC paid");
   
    //encodePacked function is to turn a bunch of strings into bytes and then combines them
    string memory _name = string(abi.encodePacked(name,".",tld));
    string memory final_svg = string(abi.encodePacked(svgPartOne, _name, svgPartTwo));
    uint256 newId = _tokenIds.current();
    uint256 length = StringUtils.strlen(name);
		string memory strLen = Strings.toString(length);

    console.log("Registering %s.%s on the contract with tokenID %d", name, tld, newId);

		// Create the JSON metadata of our NFT. We do this by combining strings and encoding as base64
    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            _name,
            '", "description": "A domain on the flappy name service", "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(final_svg)),
            '","length":"',
            strLen,
            '"}'
          )
        )
      )
    );

//As NFTs use JSON to store details like the name, description, attributes and the media. What we’re doing with json is combining strings with abi.encodePacked to make a JSON object. We’re then encoding it as a Base64 string before setting it as the token URI.
    string memory finalTokenUri = string( abi.encodePacked("data:application/json;base64,", json));

		console.log("\n--------------------------------------------------------");
	  console.log("Final tokenURI", finalTokenUri);
	  console.log("--------------------------------------------------------\n");

    _safeMint(msg.sender, newId);
    _setTokenURI(newId, finalTokenUri);


    domains[name] = msg.sender;
    console.log("%s has registered a name",msg.sender);

    names[newId] = name; //storing mint Ids with domain name in map

     _tokenIds.increment();
  }

  function getAddress(string calldata name) public view returns(address){
    return domains[name]; // Check that the owner is the transaction sender
  } 

  function setMusic(string calldata name, string calldata music) public {
   // require(domains[name]==msg.sender, "You are not the owner of domain"); //checking transaction is done by owner
    if(domains[name] != msg.sender) revert Unauthorized();
    musics[name] = music;
  }

  function getMusic(string calldata name) public view returns(string memory){
    return musics[name];
  }

  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  function isOwner() public view returns (bool) {
    return msg.sender == owner;
  }

//withdraw func() to withdraw matic from contract to owner wallet
  function withdraw() public onlyOwner {
    uint amount = address(this).balance;
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Failed to withdraw Matic");
  } 

  //Getting all domain names
  function getAllNames() public view returns(string[] memory){
    string[] memory allnames = new string[](_tokenIds.current());
    for(uint256 i=0; i < _tokenIds.current();i++){
      allnames[i] = names[i];
      console.log("Name for token %d is %s", i, allnames[i]);
    }
    return allnames;
  }
 
 //Check for long invalid domain name
  function valid(string calldata name) public pure returns(bool) {
  return StringUtils.strlen(name) >= 3 && StringUtils.strlen(name) <= 8;
}
}
// memory (whose lifetime is limited to a function call)
// storage (the location where the state variables are stored)
// calldata (this indicates the “location” of where the name argument should be stored.it takes the least amount of gas!)
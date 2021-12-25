//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract Location {

    struct UserLocation {
        uint256 locationId;
        uint256 blockNumber;
    }
    
    struct User {
        bool flag;
        UserLocation[] locations;
        uint256 points;
    }

    struct Location {
        uint256 lat;
        uint256 lon;
        string name;
        string description;
        string imageUrl;
        bool verified;
    }

    mapping(address => User) private userByAddress;

    mapping(uint256 => Location) private locationById;

    // TODO: how to get all the users that share a location
    // and block number that is within a reasonable +/-

    using Counters for Counters.Counter;
    Counters.Counter private _locationIds;
    
    constructor() {
        console.log("Deploying Location");
    }

    function getLocation(uint256 locationId) public view returns (Location memory) {
        require(locationId < _locationIds.current(), "Location does not exist");

        return locationById[locationId];
    }

    function createLocation() public returns (uint256) {
        
    }
}

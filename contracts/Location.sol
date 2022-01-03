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

    struct LocationDescription {
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
    // Store a map of blocknumber to mapping of location id to users

    // When someone switches their flag, an event is emitted, centralized
    // process figures out which users need to be notified and updates
    // the smart contract to record it

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
        // Can anyone create a location? I think so. Just needs to be verified
        // Hide non-verified in the UI
    }

    function setFlag() public {
        // require user exists
        // get user from map and set flag
        // emit event
    }

    function checkIn(uint256 locationId) public {
        // Create new userlocation with locationId
        // TODO: Should caller be a checkIn trusted address
    }

    // TODO: Need to hide a location by verifier account

    function verifyLocation(uint256 locationId) public {
        // require that location exists
        // require that verifier address made the call
        // Set verified flag
    }

    function notifyUser(address user) public {
        // get user of address, require it exists
        // set flag of user
        // TODO: Possibly set flag
    }
}

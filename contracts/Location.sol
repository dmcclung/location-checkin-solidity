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
        uint256 points;
    }

    struct LocationDescription {
        uint256 lat;
        uint256 lon;
        string name;
        string description;
        string imageUrl;
        bool verified;
        bool hide;
    }

    mapping(address => User) private userByAddress;
    mapping(address => UserLocation[]) private locationsByUser;
    mapping(uint256 => LocationDescription) private locationById;

    // How to get all the users that share a location
    // and block number that is within a reasonable +/-
    // Store a map of blocknumber to mapping of location id to users
    mapping(uint256 => mapping(uint256 => User[])) private usersByBlockNumber;

    // TODO: Figure out how to notify users
    // TODO: Update the above collection
    // TODO: Write all events

    // When someone switches their flag, an event is emitted, centralized
    // process figures out which users need to be notified and updates
    // the smart contract to record it
    event LocationCreated(uint256 locationId);
    event UserCreated(address newUser);
    event UserFlagSet(address user, bool flag);

    address private verifier;

    using Counters for Counters.Counter;
    Counters.Counter private _locationIds;
    
    constructor() {
        verifier = msg.sender;
        console.log("Deploying Location, verifier %s", verifier);
    }

    function getLocation(uint256 locationId) public view returns (LocationDescription memory) {
        require(locationId < _locationIds.current(), "Location does not exist");
        return locationById[locationId];
    }

    function createLocation(uint256 lat, 
                            uint256 lon, 
                            string memory name, 
                            string memory description,
                            string memory imageUrl) public returns (uint256) {
        // If created by verifier, set to true
        bool isVerified = false;
        // hide always false
        bool isHidden = false;
        // Can anyone create a location? I think so. Just needs to be verified
        // Hide non-verified in the UI
        LocationDescription memory location = LocationDescription(
            lat,
            lon,
            name,
            description,
            imageUrl,
            isVerified,
            isHidden
        );

        uint256 newLocationId = _locationIds.current();
        locationById[newLocationId] = location;
        emit LocationCreated(newLocationId);
        _locationIds.increment();
        return newLocationId;
    }

    function createUser() public {
        uint256 defaultPoints = 1000;
        bool flagged = false;
        userByAddress[msg.sender] = User(flagged, defaultPoints);

        emit UserCreated(msg.sender);
    }

    function setFlag(bool flag) public {
        User memory user = userByAddress[msg.sender];
        user.flag = flag;
        
        emit UserFlagSet(msg.sender, flag);
    }

    function checkIn(uint256 locationId) public {
        // Create new userlocation with locationId
    }

    function hideLocation(uint256 locationId) public {
        // require that verifier address made the call
        // require that location exists
        // set hide flag
    }

    function verifyLocation(uint256 locationId) public {
        // require that location exists
        // require that verifier address made the call
        // Set verified flag
    }

    function notifyUser(address user) public {
        // get user of address, require it exists
         
    }
}

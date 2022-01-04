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
        string nS;
        uint256 lon;
        string eW;
        string name;
        string description;
        string imageUrl;
        bool verified;
        bool hide;
    }

    mapping(address => User) private userByAddress;
    mapping(address => UserLocation[]) private locationsByUser;
    mapping(address => UserLocation[]) private possiblyFlagged;
    mapping(uint256 => LocationDescription) private locationById;

    // How to get all the users that share a location
    // and block number that is within a reasonable +/-
    // Mapping of blocknumber to mapping of location id to users
    mapping(uint256 => mapping(uint256 => User[])) private usersByBlockNumber;

    // When someone switches their flag, an event is emitted, centralized
    // process figures out which users need to be notified and updates
    // the smart contract to record it
    event LocationCreated(uint256 locationId);
    event LocationHidden(uint256 locationId);
    event LocationRevealed(uint256 locationId);
    event LocationVerified(uint256 locationId);
    event LocationUnverified(uint256 locationId);

    event UserCreated(address newUser);
    event UserFlagSet(address user, bool flag);
    event UserPossiblyFlagged(address user, address byUser, uint256 locationId, uint256 blockNumber);

    event CheckIn(uint256 locationId, address user);

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
                            string memory nS,
                            uint256 lon, 
                            string memory eW,
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
            nS,
            lon,
            eW,
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
        UserLocation memory newLocation = UserLocation(locationId, block.number);

        UserLocation[] storage userLocations = locationsByUser[msg.sender];
        userLocations.push(newLocation);

        emit CheckIn(locationId, msg.sender);
    }

    function hideLocation(uint256 locationId) public {
        require(msg.sender == verifier, "Not permitted");
        LocationDescription memory location = locationById[locationId];
        location.hide = true;
        
        emit LocationHidden(locationId);
    }

    function revealLocation(uint256 locationId) public {
        require(msg.sender == verifier, "Not permitted");
        LocationDescription memory location = locationById[locationId];
        location.hide = false;

        emit LocationRevealed(locationId);
    }

    function verifyLocation(uint256 locationId) public {
        require(msg.sender == verifier, "Not permitted");
        LocationDescription memory location = locationById[locationId];
        location.verified = true;

        emit LocationVerified(locationId);
    }

    function unverifyLocation(uint256 locationId) public {
        require(msg.sender == verifier, "Not permitted");
        LocationDescription memory location = locationById[locationId];
        location.verified = false;

        emit LocationUnverified(locationId);
    }

}

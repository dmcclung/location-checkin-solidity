//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract LocationDrop {
    
    struct User {
        uint256 dropPoints;
        uint256 lastBlockAwarded;
    }

    struct Drop {
        string message;
        address user;
        uint256 blockNumber;
        uint256 locationId;
        address verifier;
    }

    struct Location {
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

    struct Proof {
        address user;
        string proofUri;
    }

    mapping(address => User) private userByAddress;
    mapping(uint256 => Location) private locationById;

    mapping(uint256 => Drop) private dropById;
    mapping(address => uint256[]) private claimedDropsByAddress;
    mapping(uint256 => uint256[]) private unclaimedDropsByLocation;

    mapping(uint256 => Proof[]) private proofsByDropId;

    event LocationUpdated(uint256 locationId);
    event UserUpdated(address user);
    event DropMinted(uint256 dropId);
    event DropClaimed(uint256 dropId, address user);
    event ProofCreated(uint256 dropId, string proofUri, address user);

    address private verifier;

    using Counters for Counters.Counter;
    Counters.Counter private _locationIds;
    Counters.Counter private _dropIds;

    uint256 private _awardBlockHeight;
    uint256 private _dropPointsAward;
    uint256 private _mintCost;
    
    constructor(uint256 awardBlockHeight, uint256 dropPointsAward, uint256 mintCost) {
        verifier = msg.sender;
        _awardBlockHeight = awardBlockHeight;
        _dropPointsAward = dropPointsAward;
        _mintCost = mintCost;
        _dropIds.increment();
        console.log(
            "Deploying LocationDrop, verifier %s, award block height %s, drop points award %s", 
            verifier, 
            _awardBlockHeight,
            _dropPointsAward
        );
    }

    function getLocation(uint256 locationId) public view returns (Location memory) {
        require(locationId < _locationIds.current(), "Location does not exist");
        return locationById[locationId];
    }

    function createLocation(uint256 lat, 
                            string memory nS,
                            uint256 lon, 
                            string memory eW,
                            string memory name, 
                            string memory description,
                            string memory imageUrl) public {
        // Anyone can create a location
        // Only deployer can verify
        bool isVerified = false;
        // Verifier can hide locations
        bool isHidden = false;
        
        Location memory location = Location(
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
        _locationIds.increment();

        emit LocationUpdated(newLocationId);
    }

    function getUser(address user) public view returns (User memory) {
        return userByAddress[user];
    }

    function createUser() public {
        // TODO: Check for user exists
        userByAddress[msg.sender] = User(_dropPointsAward, block.number);

        emit UserUpdated(msg.sender);
    }

    function claimDropPoints() public {
        User storage user = userByAddress[msg.sender];
        require(block.number - user.lastBlockAwarded >= _awardBlockHeight, "Too soon");
        
        user.dropPoints += _dropPointsAward;
        user.lastBlockAwarded = block.number;

        emit UserUpdated(msg.sender);
    }

    function getDrop(uint256 dropId) public view returns (Drop memory) {
        return dropById[dropId];
    }

    function mintDrop(uint256 locationId, string memory message) public {
        require(locationId < _locationIds.current(), "Location does not exist");

        User storage user = userByAddress[msg.sender];

        require(user.dropPoints - _mintCost >= 0, "Not enough points");

        user.dropPoints -= _mintCost;

        Drop memory newDrop = Drop(message, msg.sender, block.number, locationId, msg.sender);
        uint256 dropId = _dropIds.current();

        dropById[dropId] = newDrop;
        unclaimedDropsByLocation[locationId].push(dropId);

        _dropIds.increment();

        emit DropMinted(dropId);
    }

    function claimDrop(uint256 locationId, uint256 dropId) public {
        require(locationId < _locationIds.current(), "Location does not exist");
        require(dropId < _dropIds.current(), "Drop does not exist");

        uint256[] memory unclaimedDropIds = unclaimedDropsByLocation[locationId];
        uint index;
        for (uint i = 0; i < unclaimedDropIds.length; i++) {
            if (unclaimedDropIds[i] == dropId) {
                index = i;
                break;
            }
        }

        uint256 unclaimedDropId = unclaimedDropIds[index];
        
        require(unclaimedDropId == dropId, "Ids not equal");

        Drop memory unclaimedDrop = dropById[unclaimedDropId];
        require(unclaimedDrop.verifier == msg.sender, "Not permitted");

        claimedDropsByAddress[msg.sender].push(unclaimedDropId);
        
        delete unclaimedDropIds[index];

        emit DropClaimed(dropId, msg.sender);
    }

    function getProofOfBeingThere(uint256 dropId) public view returns (Proof[] memory) {
        return proofsByDropId[dropId];
    }

    function setProofOfBeingThere(uint256 dropId, string memory proofUri) public {
        Proof memory proof = Proof(msg.sender, proofUri);
        proofsByDropId[dropId].push(proof);

        emit ProofCreated(dropId, proofUri, msg.sender);
    }

    function verifyDrop(address claimer, uint256 dropId) public {
        Drop storage drop = dropById[dropId];
        require(msg.sender == drop.verifier, "Not permitted");
        drop.verifier = claimer;
    }

    function hideLocation(uint256 locationId) public {
        require(locationId < _locationIds.current(), "Location does not exist");
        require(msg.sender == verifier, "Not permitted");
        locationById[locationId].hide = true;
        
        emit LocationUpdated(locationId);
    }

    function revealLocation(uint256 locationId) public {
        require(locationId < _locationIds.current(), "Location does not exist");
        require(msg.sender == verifier, "Not permitted");
        locationById[locationId].hide = false;

        emit LocationUpdated(locationId);
    }

    function verifyLocation(uint256 locationId) public {
        require(locationId < _locationIds.current(), "Location does not exist");
        require(msg.sender == verifier, "Not permitted");
        locationById[locationId].verified = true;

        emit LocationUpdated(locationId);
    }

    function unverifyLocation(uint256 locationId) public {
        require(locationId < _locationIds.current(), "Location does not exist");
        require(msg.sender == verifier, "Not permitted");
        locationById[locationId].verified = false;

        emit LocationUpdated(locationId);
    }

}

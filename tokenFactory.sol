pragma solidity ^0.5.0;

import "./myERC721.sol";

contract Artist is ERC721 {

    // Collection of artworks by this Artist
    mapping(uint => ArtWork) artworks;
    address artist;
    
    constructor() public {
        artist = msg.sender;
        _tokenOwner[0] = artist;
        _ownedTokensCount[artist].increment();
    }
    
    modifier _onlyArtist() {
        require(msg.sender == artist, "Only artist is allowed to call this function..!!");
        _;
    }
    
    function createArtwork(uint hashIPFS, string memory Name) public _onlyArtist() returns (ArtWork) {
       ArtWork artContract = new ArtWork(hashIPFS, Name, artist);
       artworks[hashIPFS] = artContract;
       return artContract;
    }
    
    function checkArtwork(uint hashIPFS) public _onlyArtist() view returns(bool) {
        if(artworks[hashIPFS] == ArtWork(0x0)) {
            return false;
        }
        return true;  
    }
    
    
    
    function sellArtWork(uint hashIPFS, address newOwner) public _onlyArtist() {
        ArtWork artContract = artworks[hashIPFS];           //get the artWork contract instance
        
        artContract.sellArtWork(hashIPFS, newOwner);        //calling sellArtWork function to sell the art work.
    }
}

contract ArtWork is ERC721 {
    
    // Detail of artwork 
    address artist;
    string  name;
    uint  hashIPFS;
    address internal owner;
    
    constructor(uint ipfsHash, string memory artName, address originalOwner) public {
        artist = msg.sender;
        name = artName;
        hashIPFS = ipfsHash;
        owner = originalOwner;
        
        _tokenOwner[hashIPFS] = owner;
        _ownedTokensCount[owner].increment();

    }
    
    modifier _onlyOwner() {
        require(msg.sender == owner, "Only owner can sell the art work..!!");
        _;
    }
    
    function setOwner(address newOwner) public {
        if(owner == msg.sender) {
            owner = newOwner;
        }
    }
    
    function  sellArtWork(uint _hashIPFS, address _to) public {
        require(ownerOf(_hashIPFS) == owner, "User is not the owner of the art work..!!");
        require(_ownedTokensCount[owner].current() > 0, "There are no tokens of Art Work..!!");
        
        _ownedTokensCount[owner].decrement();
        _ownedTokensCount[_to].increment();
        
        safeTransferFrom(owner, _to, _hashIPFS);
        setOwner(_to);
    }
    
}
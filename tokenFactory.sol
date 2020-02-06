pragma solidity ^0.5.10;

import "./myERC721.sol";

contract Artist is ERC721 {

    // Collection of artworks by this Artist
    mapping(uint => ArtWork) artworks;
    address artist;
    
    constructor() public {
        artist = msg.sender;
        _tokenOwner[0x0] = artist;
        _ownedTokensCount[artist].increment();
    }
    
    // Modifier to check the original artist
    modifier _onlyArtist() {
        require(msg.sender == artist, "Only artist is allowed to call this function..!!");
        _;
    }
    
    // function for creating the art work
    function createArtwork(uint hashIPFS, string memory Name) public _onlyArtist() returns (ArtWork) {
       ArtWork artContract = new ArtWork(hashIPFS, Name, artist);
       artworks[hashIPFS] = artContract;
       return artContract;
    }
    
    // function for checking the art work
    function checkArtwork(uint hashIPFS) public _onlyArtist() view returns(bool) {
        if(artworks[hashIPFS] == ArtWork(0x0)) {
            return false;
        }
        return true;  
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
        
        //  keep tract of owner and no of tokens for each owner..
        _tokenOwner[hashIPFS] = owner;
        _ownedTokensCount[owner].increment();

    }
    
    //  function for setting the owner of the art contract
    function setOwner(address newOwner) public {
        if(owner == msg.sender) {
            owner = newOwner;
        }
    }
    
    //  function for selling the art work..
    function  sellArtWork(uint _hashIPFS, address _to) public {
        require(_ownedTokensCount[owner].current() > 0, "There are no tokens of Art Work..!!");
        
        safeTransferFrom(owner, _to, _hashIPFS);
        setOwner(_to);
    }
    
}
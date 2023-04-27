// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;

contract multisigFacet {


    function initialize(address _owner1,address owner2) external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.admin = _msgSender();
        ds.counter = 0;
        ds.owners[owner1] = true;
        ds.owners[owner2] = true;
    }

    modifier approvedOnly {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        if(!ds.owners[msg.sender]) revert();
        _;
    }

    function setAcceptedToken(address _tokenAddress) external approvedOnly {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        if(_tokenAddress == address(0)) revert();
        ds.acceptedTokens[_tokenAddress] =true;
    }
    function depositFunds(address _token, uint amount) external {
        
    }
}
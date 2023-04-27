// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.6;
import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IERC20} from "../interfaces/IERC20.sol";

contract multisigFacet {
    function initialize(address owner1, address owner2) external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.admin = msg.sender;
        ds.counter = 0;
        ds.owners[owner1] = true;
        ds.owners[owner2] = true;
    }

    modifier approvedOnly() {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        if (!ds.owners[msg.sender]) revert();
        _;
    }

    function setAcceptedToken(address _tokenAddress) external approvedOnly {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        if (_tokenAddress == address(0)) revert();
        ds.acceptedTokens[_tokenAddress] = true;
        ds.token = IERC20(_tokenAddress);
    }

    function depositFunds(uint amount) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        if(ds.token.balanceOf(msg.sender)< amount || ds.token.allowance(msg.sender,address(this))<amount) revert();
        ds.token.transferFrom(msg.sender,address(this),amount);
    }

    function initiateWithdrawal(
        address _receiver,
        uint _amount
    ) external approvedOnly {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint w_id = ++ds.counter;
        LibDiamond.TxDetails storage txDetails = ds.transactionDetails[w_id];
        txDetails.sender = msg.sender;
        txDetails.receiver = _receiver;
        txDetails.amount = _amount;
    }

    function approveWithdrawal() external approvedOnly {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint w_id = ds.counter;
        LibDiamond.TxDetails storage txDetails = ds.transactionDetails[w_id];
        if (msg.sender == txDetails.sender) revert();
        txDetails.approver = msg.sender;
        address recepient = txDetails.receiver;
        uint amt = txDetails.amount;
        ds.token.transfer(recepient,amt);
        txDetails.txComplete;

    }
    function checkTxProgress(uint id) external view returns(address _sender, address _receiver, uint _amount, bool _txProgress){
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        LibDiamond.TxDetails storage txDetails = ds.transactionDetails[id];
        _sender = txDetails.sender;
        _receiver = txDetails.receiver;
        _amount = txDetails.amount;
        _txProgress = txDetails.txComplete;
        
       // return (_sender,_receiver,_amount,_txProgress);

    } 
}

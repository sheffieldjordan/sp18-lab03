pragma solidity ^0.4.18;

import "./AuctionInterface.sol";

/** @title GoodAuction */
contract GoodAuction is AuctionInterface {

	/* Keeps track of refunds owed */
	mapping(address => uint) public refunds;

    modifier canReduce() {
         if (msg.sender == highestBidder) {
					 _;
				 }
		}

	/* 	Bid function, now shifted to pull paradigm
		Must return true on successful send and/or bid, bidder
		reassignment. Must return false on failure and
		allow people to retrieve their funds  */
	function bid() payable external returns(bool) {
		if (msg.value > highestBid) {
		    refunds[highestBidder] = highestBid;
		    highestBidder = msg.sender;
		    highestBid = msg.value;
		    return true;
		} else {
            refunds[msg.sender] = msg.value;
            return false;
	    }
	}
	/*  Implement withdraw function to complete new
	    pull paradigm. Returns true on successful
	    return of owed funds and false on failure
	    or no funds owed.  */
	function withdrawRefund() external returns(bool) {
	    uint refundAmount = refunds[msg.sender];
	    if (refunds[msg.sender]	== 0) {
	        return false;
	    }
			if (refunds[msg.sender] != 0) {
		    refunds[msg.sender] = 0;
		    msg.sender.transfer(refundAmount);
	        return true;
	    } else {
	        return false;
	    }
	}
	/*  Allow users to check the amount they are owed
		before calling withdrawRefund(). Function returns
		amount owed.  */
	function getMyBalance() external view returns(uint) {
		return refunds[msg.sender];
	}
	/*  Rewrite reduceBid from BadAuction to fix
		the security vulnerabilities. Should allow the
		current highest bidder only to reduce their bid amount */

	function reduceBid() external canReduce {
	    if (highestBid >= 0) {
	        highestBid = highestBid - 1;
	        highestBidder.send(1);
 			} else {
				highestBid += 0;
			}
	}

    function getHighestBidder() public view returns (address) {
		return highestBidder;
	}

	function getHighestBid() public view returns (uint) {
		return highestBid;
	}


	/* 	gets invoked if somebody calls a
		function that does not exist in this
		contract; we send people their money back  */

	function () public payable {
		revert();
	}

}
